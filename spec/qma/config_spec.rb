describe QMA::Config do
  let(:key) { '1234567890' }
  let(:tmp_path) { '/tmp/qma' }

  let(:template_config_path) { File.expand_path('../../../config', __FILE__) }
  let(:template_config_name) { 'qma.yml' }
  let(:template_config) { File.join(tmp_path, template_config_name) }

  let(:fixtures_config_path) { File.expand_path('../../fixtures/config', __FILE__) }
  let(:fixtures_config_name1) { 'qma.fixtures1.yml' }
  let(:fixtures_config_name2) { 'qma.fixtures2.yml' }
  let(:fixtures_config1) { File.join(tmp_path, fixtures_config_name1) }
  let(:fixtures_config2) { File.join(tmp_path, fixtures_config_name2) }

  let(:default_config) { File.join(File.expand_path('~'), '.qma') }
  let(:backup_default_config) { File.join(File.expand_path('~'), '.qma.bak') }

  before do
    FileUtils.mkdir_p tmp_path
    FileUtils.cp_r File.join(template_config_path, template_config_name), template_config
    FileUtils.cp_r File.join(fixtures_config_path, fixtures_config_name1), fixtures_config1
    FileUtils.cp_r File.join(fixtures_config_path, fixtures_config_name2), fixtures_config2

    FileUtils.mv default_config, backup_default_config if File.exist?(default_config)
  end

  after do
    FileUtils.rm_r tmp_path
    FileUtils.mv backup_default_config, default_config
  end

  context '#initialize' do
    let(:subject) { QMA::Config.new }
    it 'should generate new one when default config file is not exist' do
      expect(File).to exist(subject.path)
    end

    it { expect(subject.key).to eq '<input-your-key>' }
    it { expect(subject.hosts.size).to eq 2 }
    it { expect(subject.external_host).to eq '<input-your-external-host>' }
    it { expect(subject.intranet_host).to eq '<input-your-intranet-host>' }
    it { expect(ENV['QMA_KEY']).to eq subject.key }
    it { expect(ENV['QMA_EXTERNAL_HOST']).to eq subject.external_host }
    it { expect(ENV['QMA_INTRANET_HOST']).to eq subject.intranet_host }

    it 'should update to file when call save method' do
      external_host = 'http://stub.qyer.dev'
      subject.key = key
      subject.external_host = external_host
      subject.save!

      yaml = YAML.load(File.open(subject.path))
      expect(yaml['host']['external']).to eq external_host
      expect(yaml['key']).to eq key
    end
  end

  context '#mergation' do
    it 'should upgraded new structs when initialize' do
      [fixtures_config1, fixtures_config2].each do |path|
        old_data = YAML.load(path)
        config = QMA::Config.new(path)

        expect(config.intranet_host).to eq old_data.try(:[], 'development').try(:[], 'host')
        expect(config.external_host).to eq old_data.try(:[], 'production').try(:[], 'host')
      end
    end
  end
end
