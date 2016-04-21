describe QMA::Client do

  let(:key) { '1234567890' }
  let(:config_path) { File.expand_path('../../../config', __FILE__) }
  let(:config_name) { 'qma.yml' }
  let(:tmp_path) { '/tmp/qma' }
  let(:config_file) { File.join(tmp_path, config_name) }

  let(:apk_file) { File.dirname(__FILE__) + '/../fixtures/apps/android.apk' }
  let(:ipa_file) { File.dirname(__FILE__) + '/../fixtures/apps/iphone.ipa' }

  before do
    FileUtils.mkdir_p tmp_path
    source = File.join(config_path, config_name)
    FileUtils.cp_r source, tmp_path
  end

  after do
    FileUtils.rm_r tmp_path
  end

  context "#initialize" do
    it "should throws an exception when key is not pass" do
      expect do
        QMA::Client.new
      end.to raise_error ArgumentError
    end

    it "should throws an exception when config file is not exist" do
      fake_config_path = "/path/to/your/config"

      expect do
        QMA::Client.new(key, config_file: fake_config_path)
      end.to raise_error QMA::NotFoundError, fake_config_path
    end

    it "should works with the default settings" do
      client = QMA::Client.new(key)

      expect(client).to be_kind_of QMA::Client
      expect(client.config).to be_kind_of QMA::Config
    end
  end

  context "#publish" do
    let(:subject) { QMA::Client.new(key, config_file: config_file) }

    it "should match intranet host" do
      expect(subject.host(:intranet)).to eq '<input-your-intranet-host>'
    end

    it "should match external host" do
      expect(subject.host(:external)).to eq '<input-your-external-host>'
    end

    it "should throw an exception when uri is invalid" do
      expect do
        subject.upload(apk_file)
      end.to raise_error URI::InvalidURIError
    end
  end

end