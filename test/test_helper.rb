$:.unshift File.dirname(__FILE__) + '/../lib'

require 'rubygems'
require 'test/unit'
require 'fileutils'

require 'cerberus/utils'

class Test::Unit::TestCase
  include Cerberus::Utils

  TEMP_DIR = File.expand_path(File.dirname(__FILE__)) + '/__workdir'

  SVN_REPO = TEMP_DIR + '/svn_repo'
  SVN_URL = 'file:///' + SVN_REPO.gsub(/\\/,'/').gsub(/^\//,'').gsub(' ', '%20')

  DARCS_REPO = TEMP_DIR + '/darcs_repo'
  DARCS_URL = 'file:///' + DARCS_REPO.gsub(/\\/,'/').gsub(/^\//,'').gsub(' ', '%20')

  HOME = TEMP_DIR + '/home'
  ENV['CERBERUS_HOME'] = HOME
  ENV['CERBERUS_ENV'] = 'TEST'

  def self.refresh_repos
    FileUtils.rm_rf TEMP_DIR
    FileUtils.mkpath SVN_REPO
    `svnadmin create "#{SVN_REPO}"`
    `svnadmin load "#{SVN_REPO}" < "#{File.dirname(__FILE__)}/data/subversion.dump"`

    require 'zip/zip'
    FileUtils.mkpath DARCS_REPO
    Zip::ZipFile::open("#{File.dirname(__FILE__)}/data/darcs.zip") {|zf|
      zf.each { |e|
        fpath = File.join(DARCS_REPO, e.name)
        FileUtils.mkdir_p(File.dirname(fpath))
        zf.extract(e, fpath)
      }
    }
  end

  refresh_repos

  CERBERUS_PATH = File.expand_path(File.dirname(__FILE__) + '/../')
  def run_cerb(args)
    `ruby -I"#{CERBERUS_PATH}/lib" "#{CERBERUS_PATH}/bin/cerberus" #{args} 2>&1`
  end

  def add_test_case_to_project(project_name, content)
    test_case_name = "#{HOME}/work/#{project_name}/sources/test/#{rand(10000)}_test.rb"
    File.open(test_case_name, 'w') { |f|
      f << "require 'test/unit'

class A#{rand(10000)}Test < Test::Unit::TestCase
  def test_ok
    #{content}
  end
end"
    }

    yield

    FileUtils.rm test_case_name
  end

  def add_application(app_name, url, options = {})
    opt = {'scm'=>{'url'=>url}, 
    'publisher'=>{
      'mail'=>{'recipients'=>'somebody@com.com', 'delivery_method' => 'test'}
    }}

    opt.deep_merge!(options)

    dump_yml(HOME + "/config/#{app_name}.yml", opt)
  end

  def add_config(options)
    dump_yml(HOME + "/config.yml", options)
  end
end

require 'cerberus/config'