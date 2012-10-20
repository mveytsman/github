# encoding: utf-8

require 'spec_helper'

describe Github::Repos, '#edit' do
  let(:user) { 'peter-murach' }
  let(:repo) { 'github' }
  let(:request_path) { "/repos/#{user}/#{repo}" }
  let(:inputs) do
    { :name => 'web',
      :description => "This is your first repo",
      :homepage => "https://github.com",
      :private => false,
      :has_issues => true,
      :has_wiki => true }
  end

  before {
    stub_patch(request_path).with(inputs).
      to_return(:body => body, :status => status,
        :headers => { :content_type => "application/json; charset=utf-8"})
  }

  after { reset_authentication_for subject }

  context "resource edited successfully" do
    let(:body)  { fixture("repos/repo.json") }
    let(:status) { 200 }

    it "should fail to edit without 'user/repo' parameters" do
      expect { github.repos.edit user, nil }.to raise_error(ArgumentError)
    end

    it "should fail to edit resource without 'name' parameter" do
      expect{
        github.repos.edit user, repo, inputs.except(:name)
      }.to raise_error(Github::Error::RequiredParams)
    end

    it "should edit the resource" do
      github.repos.edit user, repo, inputs
      a_patch("/repos/#{user}/#{repo}").with(inputs).should have_been_made
    end

    it "should return resource" do
      repository = github.repos.edit user, repo, inputs
      repository.should be_a Hashie::Mash
    end

    it "should be able to retrieve information" do
      repository = github.repos.edit user, repo, inputs
      repository.name.should == 'Hello-World'
    end
  end

  context "failed to edit resource" do
    before do
      stub_patch("/repos/#{user}/#{repo}").with(inputs).
        to_return(:body => fixture("repos/repo.json"), :status => 404,
          :headers => { :content_type => "application/json; charset=utf-8"})
    end

    it "should fail to find resource" do
      expect {
        github.repos.edit user, repo, inputs
      }.to raise_error(Github::Error::NotFound)
    end
  end
end # edit