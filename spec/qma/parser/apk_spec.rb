describe QMA::Parser::APK do
  let(:file) { File.dirname(__FILE__) + '/../../fixtures/apps/android.apk' }
  subject { QMA::Parser::APK.new(file) }

  it { expect(subject.os).to eq 'Android' }
  it { expect(subject.file).to eq file }
  it { expect(subject.apk.class).to eq Android::Apk }
  it { expect(subject.build_version).to eq('1') }
  it { expect(subject.release_version).to eq('1.0') }
  it { expect(subject.name).to eq('AppParserTest') }
  it { expect(subject.bundle_id).to eq('com.gmail.tkycule.AppParserTest') }
  it { expect(subject.identifier).to eq('com.gmail.tkycule.AppParserTest') }
  it { expect(subject.icons.length).not_to be_nil }
end
