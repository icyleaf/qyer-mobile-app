describe QMA::Config do

  let(:key) { '1234567890' }

  let(:config_path) { File.expand_path('../../../config', __FILE__) }
  let(:config_name) { 'qma.yml' }
  let(:tmp_path) { '/tmp/qma' }
  let(:config) { File.join(tmp_path, config_name) }
  let(:default_config) { File.join(File.expand_path('~'), '.qma') }
  let(:backup_default_config) { File.join(File.expand_path('~'), '.qma.bak') }

  before do
    FileUtils.mkdir_p tmp_path
    source = File.join(config_path, config_name)
    FileUtils.cp_r source, tmp_path

    FileUtils.mv default_config, backup_default_config if File.exist?(default_config)
  end

  after do
    FileUtils.rm_r tmp_path
    FileUtils.mv backup_default_config, default_config
  end

  context "#initialize" do
    let(:subject) { QMA::Config.new }
    it "should generate new one when default config file is not exist" do
      expect(File).to exist(subject.path)
    end

    it { expect(subject.key).to eq '<input-your-key>' }
    it { expect(subject.hosts.size).to eq 2 }
    it { expect(subject.external_host).to eq '<input-your-external-host>' }
    it { expect(subject.intranet_host).to eq '<input-your-intranet-host>' }

    it "should update to file when call save method" do
      external_host = 'http://stub.qyer.dev'
      subject.external_host = external_host
      subject.save!

      yaml = YAML.load(File.open(subject.path))
      expect(yaml['host']['external']).to eq external_host
    end
  end

end