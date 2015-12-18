# encoding: UTF-8
require 'spec_helper'
require 'pp'


# ======[ Special functions {{{1
RSpec.describe "Special functions", :cpp, :spe_func do
  let (:filename) { "test.cpp" }

  # ====[ Always executed before each test {{{2
  before :each do
    vim.command('filetype plugin on')
    vim.command("file #{filename}")
    vim.set('ft=cpp')
    vim.set('expandtab')
    vim.set('sw=4')
    vim.command('silent! unlet g:cpp_explicit_default')
    vim.command('silent! unlet g:cpp_std_flavour')
    if !defined? vim.runtime
        vim.define_singleton_method(:runtime) do |path|
            self.command("runtime #{path}")
        end
    end
    vim.runtime('spec/support/input-mock.vim')
    clear_buffer
  end

  # ====[ default constructor {{{2
  # Tests with parameters are done in *-class_spec.rb tests
  # Test expanding with <Plug>MuT_ckword don't seem to work correctly
  context "when expanding default-constructor", :default_ctr do
    it "asks the user, when the only context is the filename" do
      vim.command('silent! unlet g:mocked_input') # don't need it
      expect(vim.command('MuTemplate cpp/default-constructor')).to match(/^$/)
        assert_buffer_contents <<-EOF
        /**
         * Default constructor.
         * «@throw »
         */
        «Test»();
        EOF
    end

    it "takes the class name as a parameter" do
      vim.command('silent! unlet g:mocked_input') # don't need it
      expect(vim.command('MuTemplate cpp/default-constructor FooBar')).to match(/^$/)
        assert_buffer_contents <<-EOF
        /**
         * Default constructor.
         * «@throw »
         */
        FooBar();
        EOF
    end

    it "recognizes it's within a class definition" do
      vim.command('silent! unlet g:mocked_input') # don't need it
      set_buffer_contents <<-EOF
      class Foo {

      };
      EOF
      assert_buffer_contents <<-EOF
      class Foo {

      };
      EOF
      expect(vim.echo('line("$")')).to eq '3'
      expect(vim.echo('setpos(".", [1,2,1,0])')).to eq '0'
      expect(vim.echo('line(".")')).to eq '2'
      expect(vim.command('MuTemplate cpp/default-constructor')).to match(/^$/)
      assert_buffer_contents <<-EOF
      class Foo {
          /**
           * Default constructor.
           * «@throw »
           */
          Foo();
      };
      EOF
    end
  end

end

# }}}1
# vim:set sw=2: