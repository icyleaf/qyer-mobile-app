describe QMA::Client do

  let(:key) { '1234567890' }
  let(:config_path) { File.expand_path('../../../config', __FILE__) }
  let(:config_name) { 'qma.yml' }
  let(:tmp_path) { '/tmp/qma' }
  let(:config_file) { File.join(tmp_path, config_name) }


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
      end.to raise_error ArgumentErrorg
    end

    it "should throws an exception when config file is not exist" do
      fake_config_path = "/path/to/your/config"

      expect do
        QMA::Client.new(key, config_file: fake_config_path)
      end.to raise_error QMA::NotFoundError, fake_config_path
    end

    it "should works with the default setting" do
      client = QMA::Client.new(key)

      expect(client).to be_kind_of QMA::Client
      expect(client.config).to be_kind_of QMA::Config
    end
  end

  # context "#methods" do
  #
  #
  #   let(:subject) { QMA::Client.new(key, config_file:config_file) }
  #
  #   it { expect(subject.host).not_to be_nil }
  #   it { expect(subject.current_env).to eq :production }
  #   it { expect(subject.env(:development).current_env).to eq :development }
  #   it "should update config file when host is update" do
  #     url = 'stub url'
  #     env = 'production'
  #     # subject.update_host(url, env: env)
  #     ap subject.config
  #     ap subject.config_file
  #
  #     yaml = YAML.load(File.open(config_file))
  #     ap yaml
  #
  #     expect(subject.host).to eq yaml[env.to_sym][:host]
  #   end
  # end

end