require File.join(File.dirname(__FILE__), *%w[spec_helper])

describe "ActiveRecord class with has_many_images mixed in" do
  before do
    @klass = ActiveRecordStub.dup
    @klass.send(:include, Ketlai::Image::Associations)
  end
  
  it "should set up the has_many relationship" do
    @klass.should_receive(:has_many).with(:samples, {})
    @klass.send(:has_many_images, :samples)
  end
  
  describe "when updating with empty or nil data" do
    before do
      @klass.send(:has_many_images, :samples)
    end
    
    it "should not reflect on association" do
      k = @klass.new
      @klass.should_not_receive(:reflect_on_association)
      k.samples = []
    end
  end
  
  describe "when uploading a file" do
    
    before do
      @klass.send(:has_many_images, :samples)
      @association_proxy = mock('association proxy', :build => nil)
      @association_details = mock('association info')
      @klass.stub!(:reflect_on_association).with(:samples).and_return(@association_details)
      @k = @klass.new      
      @k.stub!(:samples).and_return(@association_proxy)
    end
    
    it "should build the new association" do
      sample_data = StringIO.new('fake string')
      @association_proxy.should_receive(:build).with(:uploaded_data => sample_data)
      @k.samples = [sample_data]
    end
  end
end