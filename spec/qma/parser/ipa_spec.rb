describe QMA::Parser::IPA do
  let(:file) { File.dirname(__FILE__) + '/../../fixtures/apps/iphone.ipa' }
  subject { QMA::Parser::IPA.new(file) }

  context 'subject' do
    it { expect(subject.os).to eq 'ios' }
    it { expect(subject.file).to eq file }
    it { expect(subject.build_version).to eq('1') }
    it { expect(subject.release_version).to eq('1.0') }
    it { expect(subject.name).to eq('AppParserTest') }
    it { expect(subject.bundle_name).to eq('AppParserTest') }
    it { expect(subject.display_name).to be_nil }
    it { expect(subject.identifier).to eq('com.gmail.tkycule.AppParserTest') }
    it { expect(subject.bundle_id).to eq('com.gmail.tkycule.AppParserTest') }
    it { expect(subject.device_type).to eq('universal') }
    it { expect(subject.devices).to be_nil }
    it { expect(subject.team_name).to be_nil }
    it { expect(subject.profile_name).to be_nil }
    it { expect(subject.expired_date).to be_nil }
    it { expect(subject.distribution_name).to be_nil }
    it { expect(subject.mobileprovision).to be_nil }
    it { expect(subject.mobileprovision?).to be true }
    it { expect(subject.metadata).to be_nil }
    it { expect(subject.metadata?).to be false }
    it { expect(subject.stored?).to be false }
    it { expect(subject.info).to be_kind_of Hash }
    it { expect(subject.info.length).not_to be_nil }

    it { expect(subject.icons.length).not_to be_nil }
  end
end
