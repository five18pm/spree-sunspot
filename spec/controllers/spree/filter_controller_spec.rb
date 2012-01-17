require 'spec_helper'

describe FilterController do

  describe "GET 'filter'" do
    it "returns http success" do
      get 'filter'
      response.should be_success
    end
  end

  describe "GET 'search'" do
    it "returns http success" do
      get 'search'
      response.should be_success
    end
  end

end
