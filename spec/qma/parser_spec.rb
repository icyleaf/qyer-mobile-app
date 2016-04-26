require 'securerandom'

describe QMA::App do
  let(:apk_file) { File.dirname(__FILE__) + '/../fixtures/apps/android.apk' }
  let(:ipa_file) { File.dirname(__FILE__) + '/../fixtures/apps/iphone.ipa' }

  it 'should parse when file extion is `.ipa`' do
    file = QMA::App.parse(ipa_file)
    expect(file.class).to eq(QMA::Parser::IPA)
  end

  it 'should parse when file extion is `.apk`' do
    file = QMA::App.parse(ipa_file)
    expect(file.class).to eq(QMA::Parser::IPA)
  end

  it 'should throwa an exception when file is not exist' do
    file = 'path/to/your/file'
    expect do
      QMA::App.parse(file)
    end.to raise_error(QMA::NotFoundError)
  end

  %w('txt', 'pdf', 'app', 'zip', 'rar').each do |ext|
    it "should throwa an exception when file is '.#{ext}'" do
      filename = "#{SecureRandom.uuid}.#{ext}"
      file = Tempfile.new(filename)

      expect do
        QMA::App.parse(file.path)
      end.to raise_error(QMA::NotAppError)
    end
  end
end
