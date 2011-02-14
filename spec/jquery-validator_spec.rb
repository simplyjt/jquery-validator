require 'spec_helper'

describe JqueryValidator do
  before(:each) do
    @builder = double('builder')
    @builder.stub(:object_name).and_return(:Post)
    @validator = double('validator')
    @validator.stub(:attributes).and_return( [:title, :description] )
    @validator.stub(:options).and_return({})
  end

  describe JqueryValidator::PresenceValidator do
    include JqueryValidator

      it "creates appropriate hash" do 
        jv = JqueryValidator::PresenceValidator.new(@builder, @validator)  
        jv.validate_attributes.should == {:rules=>{"Post[title]"=>{"required"=>true}, "Post[description]"=>{"required"=>true}}}
      end 
      
      it "creates appropriate hash w/ only" do 
        jv = JqueryValidator::PresenceValidator.new(@builder, @validator, :title)  
        jv.validate_attributes.should == {:rules=>{"Post[title]"=>{"required"=>true}}}
      end
      
      it "creates appropriate hash w/ only as array" do 
        jv = JqueryValidator::PresenceValidator.new(@builder, @validator, [:title])  
        jv.validate_attributes.should == {:rules=>{"Post[title]"=>{"required"=>true}}}
      end
      
      it "supports custom message" do
        @validator.stub(:attributes).and_return( [:title] )
        @validator.stub(:options).and_return({:message=>"this is a customized failure message"})  
        jv = JqueryValidator::PresenceValidator.new(@builder, @validator)          
        jv.validate_attributes.should == {:rules=>{"Post[title]"=>{"required"=>true}}, :messages => {'Post[title]' => "this is a customized failure message"} }
      end
      
      it "supports proc with :if/:unless" do
        @validator.stub(:attributes).and_return( [:title] )
        @validator.stub(:options).and_return({:if=>Proc.new { false }}) 
        jv = JqueryValidator::PresenceValidator.new(@builder, @validator)          
        jv.validate_attributes.should == {}

        @validator.stub(:options).and_return({:unless=>Proc.new { true }}) 
        jv = JqueryValidator::PresenceValidator.new(@builder, @validator)          
        jv.validate_attributes.should == {}
        
        @validator.stub(:options).and_return({:if=>Proc.new { true }}) 
        jv = JqueryValidator::PresenceValidator.new(@builder, @validator)          
        jv.validate_attributes.should == {:rules=>{"Post[title]"=>{"required"=>true}}}
      end
      
      it "supports method with :if/:unless" do
        @validator.stub(:attributes).and_return( [:title] )      
        
        @validator.stub(:options).and_return({:if => :validate?})
        @builder.stub_chain(:object, :validate?).and_return(false)
        jv = JqueryValidator::PresenceValidator.new(@builder, @validator)          
        jv.validate_attributes.should == {}

        @validator.stub(:options).and_return({:unless => :validate?})        
        @builder.stub_chain(:object, :validate?).and_return(true)
        jv = JqueryValidator::PresenceValidator.new(@builder, @validator)          
        jv.validate_attributes.should == {}
        
        @validator.stub(:options).and_return({:if => :validate?})
        @builder.stub_chain(:object, :validate?).and_return(true)
        jv = JqueryValidator::PresenceValidator.new(@builder, @validator)          
        jv.validate_attributes.should == {:rules=>{"Post[title]"=>{"required"=>true}}}
      end
      
  end
  
  describe JqueryValidator::AcceptanceValidator do
      it "creates appropriate hash" do        
        jv = JqueryValidator::AcceptanceValidator.new(@builder, @validator)  
        jv.validate_attributes.should == {:rules=>{"Post[title]"=>{:accepts=>true}, "Post[description]"=>{:accepts=>true}}}
      end 
  end
  
  describe JqueryValidator::ConfirmationValidator do
      it "creates appropriate hash" do        
        jv = JqueryValidator::ConfirmationValidator.new(@builder, @validator)  
        jv.validate_attributes.should == {:rules=>{"Post[title_confirmation]"=>{:equalTo=>"#Post_title"}, "Post[description_confirmation]"=>{:equalTo=>"#Post_description"}}}
      end 
  end
  
  # describe JqueryValidator::ExclusionValidator do
  #     it "creates appropriate hash" do        
  # @validator.stub(:options).and_return({:in => 30..35})  
  #       jv = JqueryValidator::ExclusionValidator.new(@builder, @validator)  
  #       jv.validate_attributes.should == {:rules=>{"Post[title]"=>{:excludes=>30..35}, "Post[description]"=>{:excludes=>30..35}}}
  #     end 
  # end
end

