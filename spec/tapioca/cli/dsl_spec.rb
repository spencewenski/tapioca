# typed: true
# frozen_string_literal: true

require "cli_spec"

module Tapioca
  class DslSpec < CliSpec
    describe("#dsl") do
      it "does not generate anything if there are no matching constants" do
        output = execute("dsl", "User")

        assert_equal(<<~OUTPUT, output)
          Loading Rails application... Done
          Loading DSL generator classes... Done
          Compiling DSL RBI files...

          No classes/modules can be matched for RBI generation.
          Please check that the requested classes/modules include processable DSL methods.
        OUTPUT

        refute_path_exists("#{outdir}/baz/role.rbi")
        refute_path_exists("#{outdir}/job.rbi")
        refute_path_exists("#{outdir}/post.rbi")
        refute_path_exists("#{outdir}/namespace/comment.rbi")
        refute_path_exists("#{outdir}/user.rbi")
      end

      it "generates RBI files for only required constants" do
        output = execute("dsl", "Post")

        assert_equal(<<~OUTPUT, output)
          Loading Rails application... Done
          Loading DSL generator classes... Done
          Compiling DSL RBI files...

          Wrote: #{outdir}/post.rbi

          Done
          All operations performed in working directory.
          Please review changes and commit them.
        OUTPUT

        refute_path_exists("#{outdir}/baz/role.rbi")
        refute_path_exists("#{outdir}/job.rbi")
        assert_path_exists("#{outdir}/post.rbi")
        refute_path_exists("#{outdir}/namespace/comment.rbi")
        refute_path_exists("#{outdir}/user.rbi")

        assert_equal(<<~CONTENTS.chomp, File.read("#{outdir}/post.rbi"))
          # DO NOT EDIT MANUALLY
          # This is an autogenerated file for dynamic methods in `Post`.
          # Please instead update this file by running `bin/tapioca dsl Post`.

          # typed: true
          class Post
            sig { returns(T.nilable(::String)) }
            def title; end

            sig { params(title: T.nilable(::String)).returns(T.nilable(::String)) }
            def title=(title); end
          end
        CONTENTS
      end

      it "errors for unprocessable required constants" do
        output = execute("dsl", ["NonExistent::Foo", "NonExistent::Bar", "NonExistent::Baz"])

        assert_equal(<<~OUTPUT, output)
          Loading Rails application... Done
          Loading DSL generator classes... Done
          Compiling DSL RBI files...

          Error: Cannot find constant 'NonExistent::Foo'
          Error: Cannot find constant 'NonExistent::Bar'
          Error: Cannot find constant 'NonExistent::Baz'
        OUTPUT

        refute_path_exists("#{outdir}/baz/role.rbi")
        refute_path_exists("#{outdir}/job.rbi")
        refute_path_exists("#{outdir}/post.rbi")
        refute_path_exists("#{outdir}/namespace/comment.rbi")
        refute_path_exists("#{outdir}/user.rbi")
      end

      it "removes RBI files for unprocessable required constants" do
        FileUtils.mkdir_p("#{outdir}/non_existent")
        FileUtils.touch("#{outdir}/non_existent/foo.rbi")
        FileUtils.touch("#{outdir}/non_existent/baz.rbi")

        output = execute("dsl", ["NonExistent::Foo", "NonExistent::Bar", "NonExistent::Baz"])

        assert_equal(<<~OUTPUT, output)
          Loading Rails application... Done
          Loading DSL generator classes... Done
          Compiling DSL RBI files...

          Error: Cannot find constant 'NonExistent::Foo'
          -- Removing: #{outdir}/non_existent/foo.rbi
          Error: Cannot find constant 'NonExistent::Bar'
          Error: Cannot find constant 'NonExistent::Baz'
          -- Removing: #{outdir}/non_existent/baz.rbi
        OUTPUT

        refute_path_exists("#{outdir}/non_existent/foo.rbi")
        refute_path_exists("#{outdir}/non_existent/baz.rbi")

        refute_path_exists("#{outdir}/baz/role.rbi")
        refute_path_exists("#{outdir}/job.rbi")
        refute_path_exists("#{outdir}/post.rbi")
        refute_path_exists("#{outdir}/namespace/comment.rbi")
        refute_path_exists("#{outdir}/user.rbi")
      end

      it "generates RBI files for all processable constants" do
        output = execute("dsl")

        assert_equal(<<~OUTPUT, output)
          Loading Rails application... Done
          Loading DSL generator classes... Done
          Compiling DSL RBI files...

          Wrote: #{outdir}/baz/role.rbi
          Wrote: #{outdir}/job.rbi
          Wrote: #{outdir}/namespace/comment.rbi
          Wrote: #{outdir}/post.rbi

          Done
          All operations performed in working directory.
          Please review changes and commit them.
        OUTPUT

        assert_path_exists("#{outdir}/baz/role.rbi")
        assert_path_exists("#{outdir}/job.rbi")
        assert_path_exists("#{outdir}/post.rbi")
        assert_path_exists("#{outdir}/namespace/comment.rbi")
        refute_path_exists("#{outdir}/user.rbi")

        assert_equal(<<~CONTENTS.chomp, File.read("#{outdir}/baz/role.rbi"))
          # DO NOT EDIT MANUALLY
          # This is an autogenerated file for dynamic methods in `Baz::Role`.
          # Please instead update this file by running `bin/tapioca dsl Baz::Role`.

          # typed: true
          module Baz
            class Role
              sig { returns(T.nilable(::String)) }
              def title; end

              sig { params(title: T.nilable(::String)).returns(T.nilable(::String)) }
              def title=(title); end
            end
          end
        CONTENTS

        assert_equal(<<~CONTENTS.chomp, File.read("#{outdir}/job.rbi"))
          # DO NOT EDIT MANUALLY
          # This is an autogenerated file for dynamic methods in `Job`.
          # Please instead update this file by running `bin/tapioca dsl Job`.

          # typed: true
          class Job
            sig { params(foo: T.untyped, bar: T.untyped).returns(String) }
            def self.perform_async(foo, bar); end

            sig { params(interval: T.any(DateTime, Time), foo: T.untyped, bar: T.untyped).returns(String) }
            def self.perform_at(interval, foo, bar); end

            sig { params(interval: Numeric, foo: T.untyped, bar: T.untyped).returns(String) }
            def self.perform_in(interval, foo, bar); end
          end
        CONTENTS

        assert_equal(<<~CONTENTS.chomp, File.read("#{outdir}/post.rbi"))
          # DO NOT EDIT MANUALLY
          # This is an autogenerated file for dynamic methods in `Post`.
          # Please instead update this file by running `bin/tapioca dsl Post`.

          # typed: true
          class Post
            sig { returns(T.nilable(::String)) }
            def title; end

            sig { params(title: T.nilable(::String)).returns(T.nilable(::String)) }
            def title=(title); end
          end
        CONTENTS

        assert_equal(<<~CONTENTS.chomp, File.read("#{outdir}/namespace/comment.rbi"))
          # DO NOT EDIT MANUALLY
          # This is an autogenerated file for dynamic methods in `Namespace::Comment`.
          # Please instead update this file by running `bin/tapioca dsl Namespace::Comment`.

          # typed: true
          module Namespace
            class Comment
              sig { returns(::String) }
              def body; end

              sig { params(body: ::String).returns(::String) }
              def body=(body); end
            end
          end
        CONTENTS
      end

      it "can generates RBI files quietly" do
        output = execute("dsl", "--quiet")

        assert_equal(<<~OUTPUT, output)
          Loading Rails application... Done
          Loading DSL generator classes... Done
          Compiling DSL RBI files...


          Done
          All operations performed in working directory.
          Please review changes and commit them.
        OUTPUT

        assert_path_exists("#{outdir}/baz/role.rbi")
        assert_path_exists("#{outdir}/job.rbi")
        assert_path_exists("#{outdir}/post.rbi")
        assert_path_exists("#{outdir}/namespace/comment.rbi")
        refute_path_exists("#{outdir}/user.rbi")
      end

      it "generates RBI files without header" do
        execute("dsl", ["--no-file-header", "Post"])

        assert_equal(<<~CONTENTS.chomp, File.read("#{outdir}/post.rbi"))
          # typed: true
          class Post
            sig { returns(T.nilable(::String)) }
            def title; end

            sig { params(title: T.nilable(::String)).returns(T.nilable(::String)) }
            def title=(title); end
          end
        CONTENTS
      end

      it "removes stale RBI files" do
        FileUtils.mkdir_p("#{outdir}/to_be_deleted")
        FileUtils.touch("#{outdir}/to_be_deleted/foo.rbi")
        FileUtils.touch("#{outdir}/to_be_deleted/baz.rbi")
        FileUtils.touch("#{outdir}/does_not_exist.rbi")

        output = execute("dsl")

        assert_equal(<<~OUTPUT, output)
          Loading Rails application... Done
          Loading DSL generator classes... Done
          Compiling DSL RBI files...

          Wrote: #{outdir}/baz/role.rbi
          Wrote: #{outdir}/job.rbi
          Wrote: #{outdir}/namespace/comment.rbi
          Wrote: #{outdir}/post.rbi

          Removing stale RBI files...
          -- Removing: #{outdir}/does_not_exist.rbi
          -- Removing: #{outdir}/to_be_deleted/baz.rbi
          -- Removing: #{outdir}/to_be_deleted/foo.rbi

          Done
          All operations performed in working directory.
          Please review changes and commit them.
        OUTPUT

        refute_path_exists("#{outdir}/does_not_exist.rbi")
        refute_path_exists("#{outdir}/to_be_deleted/foo.rbi")
        refute_path_exists("#{outdir}/to_be_deleted/baz.rbi")

        assert_path_exists("#{outdir}/baz/role.rbi")
        assert_path_exists("#{outdir}/job.rbi")
        assert_path_exists("#{outdir}/post.rbi")
        assert_path_exists("#{outdir}/namespace/comment.rbi")
        refute_path_exists("#{outdir}/user.rbi")
      end

      it "removes stale RBI files of requested constants" do
        FileUtils.touch("#{outdir}/user.rbi")

        output = execute("dsl", ["Post", "User"])

        assert_equal(<<~OUTPUT, output)
          Loading Rails application... Done
          Loading DSL generator classes... Done
          Compiling DSL RBI files...

          Wrote: #{outdir}/post.rbi

          Removing stale RBI files...
          -- Removing: #{outdir}/user.rbi

          Done
          All operations performed in working directory.
          Please review changes and commit them.
        OUTPUT

        refute_path_exists("#{outdir}/baz/role.rbi")
        refute_path_exists("#{outdir}/job.rbi")
        assert_path_exists("#{outdir}/post.rbi")
        refute_path_exists("#{outdir}/namespace/comment.rbi")
        refute_path_exists("#{outdir}/user.rbi")
      end

      it "must respect generators option" do
        output = execute("dsl", "", generators: "SidekiqWorker Foo::Generator")

        assert_equal(<<~OUTPUT, output)
          Loading Rails application... Done
          Loading DSL generator classes... Done
          Compiling DSL RBI files...

          Wrote: #{outdir}/job.rbi

          Done
          All operations performed in working directory.
          Please review changes and commit them.
        OUTPUT

        refute_path_exists("#{outdir}/baz/role.rbi")
        assert_path_exists("#{outdir}/job.rbi")
        refute_path_exists("#{outdir}/post.rbi")
        refute_path_exists("#{outdir}/namespace/comment.rbi")
        refute_path_exists("#{outdir}/user.rbi")
      end

      it "errors if there are no matching generators" do
        output = execute("dsl", "", generators: "NonexistentGenerator")

        assert_equal(<<~OUTPUT, output)
          Loading Rails application... Done
          Loading DSL generator classes... Done
          Compiling DSL RBI files...

          Error: Cannot find generator 'NonexistentGenerator'
        OUTPUT

        refute_path_exists("#{outdir}/baz/role.rbi")
        refute_path_exists("#{outdir}/job.rbi")
        refute_path_exists("#{outdir}/post.rbi")
        refute_path_exists("#{outdir}/namespace/comment.rbi")
        refute_path_exists("#{outdir}/user.rbi")
      end

      it "must respect exclude_generators option" do
        output = execute("dsl", "", exclude_generators: "SidekiqWorker Foo::Generator")

        assert_equal(<<~OUTPUT, output)
          Loading Rails application... Done
          Loading DSL generator classes... Done
          Compiling DSL RBI files...

          Wrote: #{outdir}/baz/role.rbi
          Wrote: #{outdir}/namespace/comment.rbi
          Wrote: #{outdir}/post.rbi

          Done
          All operations performed in working directory.
          Please review changes and commit them.
        OUTPUT

        assert_path_exists("#{outdir}/baz/role.rbi")
        refute_path_exists("#{outdir}/job.rbi")
        assert_path_exists("#{outdir}/post.rbi")
        assert_path_exists("#{outdir}/namespace/comment.rbi")
        refute_path_exists("#{outdir}/user.rbi")
      end

      it "errors if there are no matching exclude_generators" do
        output = execute("dsl", "", exclude_generators: "NonexistentGenerator")

        assert_equal(<<~OUTPUT, output)
          Loading Rails application... Done
          Loading DSL generator classes... Done
          Compiling DSL RBI files...

          Error: Cannot find generator 'NonexistentGenerator'
        OUTPUT

        refute_path_exists("#{outdir}/baz/role.rbi")
        refute_path_exists("#{outdir}/job.rbi")
        refute_path_exists("#{outdir}/post.rbi")
        refute_path_exists("#{outdir}/namespace/comment.rbi")
        refute_path_exists("#{outdir}/user.rbi")
      end

      describe("verify") do
        describe("with no changes") do
          before do
            execute("dsl")
          end

          it "does nothing and returns exit_status 0" do
            output = execute("dsl", "--verify")

            assert_includes(output, <<~OUTPUT)
              Nothing to do, all RBIs are up-to-date.
            OUTPUT
            assert_includes($?.to_s, "exit 0") # rubocop:disable Style/SpecialGlobalVars
          end
        end

        describe("with excluded files") do
          before do
            execute("dsl")
          end

          it "advises of removed file(s) and returns exit_status 1" do
            output = execute("dsl", "--verify", exclude_generators: "SidekiqWorker")

            assert_equal(output, <<~OUTPUT)
              Loading Rails application... Done
              Loading DSL generator classes... Done
              Checking for out-of-date RBIs...


              RBI files are out-of-date. In your development environment, please run:
                `bin/tapioca dsl`
              Once it is complete, be sure to commit and push any changes

              Reason:
                File(s) removed:
                - #{outdir}/job.rbi
            OUTPUT
            assert_includes($?.to_s, "exit 1") # rubocop:disable Style/SpecialGlobalVars
          end
        end

        describe("with new file") do
          before do
            execute("dsl")
            File.write(repo_path / "lib" / "image.rb", <<~RUBY)
              # typed: true
              # frozen_string_literal: true

              class Image
                include(SmartProperties)

                property :title, accepts: String
              end
            RUBY
          end

          after do
            FileUtils.rm_f(repo_path / "lib" / "image.rb")
          end

          it "advises of new file(s) and returns exit_status 1" do
            output = execute("dsl", "--verify")

            assert_equal(output, <<~OUTPUT)
              Loading Rails application... Done
              Loading DSL generator classes... Done
              Checking for out-of-date RBIs...


              RBI files are out-of-date. In your development environment, please run:
                `bin/tapioca dsl`
              Once it is complete, be sure to commit and push any changes

              Reason:
                File(s) added:
                - #{outdir}/image.rbi
            OUTPUT
            assert_includes($?.to_s, "exit 1") # rubocop:disable Style/SpecialGlobalVars
          end
        end

        describe("with modified file") do
          before do
            File.write(repo_path / "lib" / "image.rb", <<~RUBY)
              # typed: true
              # frozen_string_literal: true

              class Image
                include(SmartProperties)

                property :title, accepts: String
              end
            RUBY
            execute("dsl")
            File.write(repo_path / "lib" / "image.rb", <<~RUBY)
              # typed: true
              # frozen_string_literal: true

              class Image
                include SmartProperties

                property :title, accepts: String
                property :src, accepts: String
              end
            RUBY
          end

          after do
            FileUtils.rm_f(repo_path / "lib" / "image.rb")
          end

          it "advises of modified file(s) and returns exit status 1" do
            output = execute("dsl", "--verify")

            assert_equal(output, <<~OUTPUT)
              Loading Rails application... Done
              Loading DSL generator classes... Done
              Checking for out-of-date RBIs...


              RBI files are out-of-date. In your development environment, please run:
                `bin/tapioca dsl`
              Once it is complete, be sure to commit and push any changes

              Reason:
                File(s) changed:
                - #{outdir}/image.rbi
            OUTPUT
            assert_includes($?.to_s, "exit 1") # rubocop:disable Style/SpecialGlobalVars
          end
        end
      end
    end
  end
end
