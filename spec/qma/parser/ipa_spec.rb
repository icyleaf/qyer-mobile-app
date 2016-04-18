describe QMA::Parser::IPA do
  let(:file) { File.dirname(__FILE__) + '/../../fixtures/apps/iphone.ipa' }
  subject { QMA::Parser::IPA.new(file) }

  it "ddd " do
    ap subject.app_icons
  end


  # it { expect(subject.os).to eq 'ios' }
  # it { expect(subject.file).to eq file }
  # it { expect(subject.build_version).to eq("1") }
  # it { expect(subject.release_version).to eq("1.0") }
  # it { expect(subject.app_name).to eq("AppParserTest") }
  # it { expect(subject.identifier).to eq("com.gmail.tkycule.AppParserTest") }
  # it { expect(subject.bundle_id).to eq("com.gmail.tkycule.AppParserTest") }

  # it { expect(subject.icons(dimensions: 48)[:file_name]).to eq("res/mipmap-mdpi-v4/ic_launcher.png") }
  # it { expect(subject.icons(dimensions: [48, 48])[:file_name]).to eq("res/mipmap-mdpi-v4/ic_launcher.png") }
  # it { expect(subject.largest_icon[:file_name]).to eq("res/mipmap-xxxhdpi-v4/ic_launcher.png") }
  # it { expect(subject.smallest_icon[:file_name]).to eq("res/mipmap-mdpi-v4/ic_launcher.png") }
  # it { expect(subject.icon_data("res/mipmap-mdpi-v4/ic_launcher.png").size).not_to be_nil }
end