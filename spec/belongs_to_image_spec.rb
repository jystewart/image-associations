require File.join(File.dirname(__FILE__), *%w[spec_helper])

describe "ActiveRecord class with belongs_to_image mixed in" do
  before do
    @klass = ActiveRecordStub.dup
    @klass.send(:include, Ketlai::Image::Associations)
  end
  
  it "should set up the belongs_to relationship" do
    @klass.should_receive(:belongs_to).with(:sample, {})
    @klass.send(:belongs_to_image, :sample)
  end
  
  describe "when updating with empty or nil data" do
    before do
      @klass.send(:belongs_to_image, :sample)
    end
    
    it "should not reflect on association" do
      k = @klass.new
      @klass.should_not_receive(:reflect_on_association)
      k.sample = nil
    end
  end
  
  describe "when uploading a file" do
    
    before do
      @klass.send(:belongs_to_image, :sample)
      @association_details = mock('association details', :build => nil, 
        :class_name => 'FakeImageStub', :association_foreign_key => 'fake_image_stub_id')
      @klass.stub!(:reflect_on_association).with(:sample).and_return(@association_details)
      @k = @klass.new
      @sample_data = StringIO.new('sample data')
    end
    
    def upload_file
      @k.sample = @sample_data
    end
    
    it "should build the new association" do
      FakeImageStub.should_receive(:create!).with(:uploaded_data => @sample_data)
      upload_file
    end
    
    it "should set the foreign key to that of the new object" do
      @k.should_receive(:write_attribute).with('fake_image_stub_id', 4)
      upload_file
    end
  end
end