require 'rails_helper'

RSpec.describe LogFileParser do

  before do
    file = Rails.root.join('lib', 'votes.txt')
    @logfile_parser = LogFileParser.new(file)
    @campaigns = @logfile_parser.instance_variable_get(:@campaigns)
    @errors = @logfile_parser.instance_variable_get(:@errors)
    @line = "VOTE 1168041805 Campaign:ssss_uk_01B Validity:during Choice:Antony CONN:MIG01TU MSISDN:00777778359999 GUID:E6109CA1-7756-45DC-8EE7-677CA7C3D7F3 Shortcode:63334"
  end

   describe '#new' do

     it "shold have valid line" do
       expect(@logfile_parser.file.readlines.first.chop).to eq(@line)
       expect(@campaigns).to eq({"Campaign" =>{}})
     end

   end

   describe '#policy_matched' do

     it 'should be matched' do
       output = @logfile_parser.policy_matched(@line)
       expect(output).to be_truthy
     end

     it 'has no "VOTE" word, should not be matched' do
       line = "DEFAULT 1168041805 Campaign:ssss_uk_01B Validity:during Choice:Antony CONN:MIG01TU MSISDN:00777778359999 GUID:E6109CA1-7756-45DC-8EE7-677CA7C3D7F3 Shortcode:63334"
       output = @logfile_parser.policy_matched(line)
       expect(output).to_not be_truthy
     end

     it 'has no "Validity:during" should not be matched' do
       line = "VOTE 1168041805 Campaign:ssss_uk_01B Validity:pre Choice:Antony CONN:MIG01TU MSISDN:00777778359999 GUID:E6109CA1-7756-45DC-8EE7-677CA7C3D7F3 Shortcode:63334"
       output = @logfile_parser.policy_matched(line)
       expect(output).to_not be_truthy
     end

     it 'has no "Validity:during" should have error counted' do
       line = "VOTE 1168041805 Campaign:ssss_uk_01B Validity:pre Choice:Antony CONN:MIG01TU MSISDN:00777778359999 GUID:E6109CA1-7756-45DC-8EE7-677CA7C3D7F3 Shortcode:63334"
       output = @logfile_parser.policy_matched(line)
       expect(output).to_not be_truthy
       expect(@errors[:errors]).to eq(1)
     end

     it 'has no "Choice:" should have error counted' do
       line = "VOTE 1168041805 Campaign:ssss_uk_01B Validity:pre Choice: CONN:MIG01TU MSISDN:00777778359999 GUID:E6109CA1-7756-45DC-8EE7-677CA7C3D7F3 Shortcode:63334"
       output = @logfile_parser.policy_matched(line)
       expect(output).to_not be_truthy
       expect(@errors[:errors]).to eq(1)
     end

     describe '#current_record_from' do

       it 'should return Openstruct object' do
         record = @logfile_parser.current_record_from(@line)
         expect(record).to be_a(OpenStruct)
       end

       it 'OpentStruct should has Campaign method' do
         output = @logfile_parser.current_record_from(@line)
         expect(output.Campaign).to eq('ssss_uk_01B')
       end

       it 'OpenStruct should has Choice method' do
         output = @logfile_parser.current_record_from(@line)
         expect(output.Choice).to eq('Antony')
       end

     end

     describe '#start_to_vote' do

       context 'for current campaign' do

         it 'Choice should be added to @campaigns collection' do
           record = @logfile_parser.current_record_from(@line)
           @logfile_parser.start_to_vote(record)
           expect(@campaigns["Campaign"]).to eq({"ssss_uk_01B"=>{"Choice"=>{"Antony"=>1}}})
         end

         it 'should not be added to @campaigns collection' do
           record = @logfile_parser.current_record_from(@line)
           record.Choice = nil
           @logfile_parser.start_to_vote(record)
           expect(@campaigns["Campaign"]).to eq({})
         end

         it 'should count errors when Choice is blank' do
           record = @logfile_parser.current_record_from(@line)
           record.Choice = nil
           @logfile_parser.start_to_vote(record)
           expect(@campaigns["Campaign"]).to eq({})
           expect(@errors[:errors]).to eq(1)
         end

       end

     end

     describe '#allready_voted_for' do

       context 'for current campaign' do

         it 'should summup choices in @campaigns collection' do
           record = @logfile_parser.current_record_from(@line)
           @logfile_parser.start_to_vote(record)
           1.upto(3) do
             @logfile_parser.allready_voted_for(record)
           end
           expect(@campaigns["Campaign"]).to eq({"ssss_uk_01B"=>{"Choice"=>{"Antony"=>4}}})
         end
       end

     end

    describe '#parse' do
      before do
        @logfile_parser.parse
      end

      it 'should have collection of campaigns' do
        campaigns =["ssss_uk_01B", "Emmerdale", "ssss_uk_02A", "ssss_uk_02B"]
        expect(@campaigns["Campaign"].keys).to eq(campaigns)
      end

      it 'should have many choices for first campaign in the list' do
        output = {"Antony"=>19, "Leon"=>1, "Tupele"=>122, "Jane"=>68,
                  "Mark"=>9, "Verity"=>4, "Matthew"=>10, "Gemma"=>8,
                  "Hayley"=>11, "Alan"=>9, "Elaine"=>2}

        expect(@campaigns["Campaign"]['ssss_uk_01B']['Choice']).to eq(output)
      end

      it 'should output hash with campaigns and its choices' do
        output = {"Campaign"=>{"ssss_uk_01B"=>
                               {"Choice"=>{"Antony"=>19, "Leon"=>1, "Tupele"=>122, "Jane"=>68, "Mark"=>9,
                                           "Verity"=>4, "Matthew"=>10, "Gemma"=>8, "Hayley"=>11, "Alan"=>9,
                                           "Elaine"=>2}},
                              "Emmerdale"=>
                               {"Choice"=>{"GRAYSON"=>14, "LEN"=>7, "ROSEMARY"=>28, "JIMMY"=>5, "JAMIE"=>6,
                                           "CARL"=>3, "MATTHEW"=>11, "TERRY"=>2, "BOB"=>1}},
                              "ssss_uk_02A"=>
                               {"Choice"=>{"Alan"=>1122, "Mark"=>943, "Leon"=>631, "Antony"=>2004,
                                           "Gemma"=>873, "Tupele"=>467, "Matthew"=>298, "Hayley"=>51,
                                           "Verity"=>1233}},
                              "ssss_uk_02B"=>
                               {"Choice"=>{"Antony"=>24, "Alan"=>12, "Verity"=>15, "Mark"=>12,
                                           "Gemma"=>13, "Leon"=>3244, "Jane"=>2, "Tupele"=>5,
                                           "Matthew"=>1123, "Hayley"=>2}}}}
        expect(@campaigns).to eq(output)
      end
    end

   end
end
