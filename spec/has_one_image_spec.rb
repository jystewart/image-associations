require File.join(File.dirname(__FILE__), *%w[spec_helper])

describe "ActiveRecord class with has_one_image mixed in" do
  before do
    @klass = ActiveRecordStub.dup
    @klass.send(:include, Ketlai::Image::Associations)
  end
  
  it "should set up the has_one relationship" do
    @klass.should_receive(:has_one).with(:samples, {})
    @klass.send(:has_one_image, :samples)
  end
  
  describe "when updating with empty or nil data" do
    before do
      @klass.send(:has_one_image, :sample)
    end
    
    it "should not reflect on association" do
      k = @klass.new
      @klass.should_not_receive(:reflect_on_association)
      k.sample = nil
    end
  end
  
  describe "when uploading a file" do
    
    before do
      @klass.send(:has_one_image, :sample)
      @association_proxy = mock('association proxy', :build_sample => nil)
      @association_details = mock('association info')
      @klass.stub!(:reflect_on_association).with(:sample).and_return(@association_details)
      @k = @klass.new      
      @k.stub!(:sample).and_return(@association_proxy)
    end
    
    it "should build the new association" do
      sample_data = StringIO.new('fake string')
      @k.should_receive(:build_sample).with(:uploaded_data => sample_data)
      @k.sample = sample_data
    end
  end
end