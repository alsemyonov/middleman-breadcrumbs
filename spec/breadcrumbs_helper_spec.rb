require 'spec_helper'

require 'middleman-breadcrumbs/breadcrumbs_helper'

describe BreadcrumbsHelper do
  before do
    @helper = Object.new
    @helper_class = @helper.singleton_class
  end

  describe '.included' do
    describe 'link_to is defined' do
      it 'does not include Padrino::Helpers' do
        methods = @helper_class.instance_methods
        @helper_class.stub :instance_methods, methods + [:link_to] do
          @helper_class.send :include, BreadcrumbsHelper
          @helper_class.wont_include Padrino::Helpers
        end
      end
    end

    describe 'link_to is not defined' do
      it 'includes Padrino::Helpers' do
        @helper_class.send :include, BreadcrumbsHelper
        @helper_class.must_include Padrino::Helpers
      end
    end
  end

  describe '#breadcrumbs' do
    before do
      @helper.singleton_class.send :include, BreadcrumbsHelper
      self.singleton_class.send :include, Padrino::Helpers
      @page = page
    end

    describe 'top-level page' do
      it 'returns a link to the page' do
        @helper.breadcrumbs(@page).must_equal link_to(@page.data.title, "/#{@page.path}")
      end
    end

    describe 'non-top-level page' do
      it 'joins all links to parent pages with > signs' do
        parent = page
        grandparent = page
        @page.parent = parent
        @page.parent.parent = grandparent

        @helper.breadcrumbs(@page).must_equal([grandparent, parent, @page].collect do |level|
          link_to level.data.title, "/#{level.path}"
        end.join ' &gt; ')
      end
    end
  end

  private

  def page
    path = Faker::Internet.http_url
    title = Faker::Lorem.sentence
    data = OpenStruct.new title: title
    OpenStruct.new data: data, path: path
  end
end