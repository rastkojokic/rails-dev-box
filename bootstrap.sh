# The output of all these installation steps is noisy. With this utility
# the progress report is nice and concise.
function install {
    echo installing $1
    shift
    apt-get -y install "$@" >/dev/null 2>&1
}

echo updating package information
apt-add-repository -y ppa:brightbox/ruby-ng >/dev/null 2>&1
apt-get -y update >/dev/null 2>&1

install 'development tools' build-essential

install Ruby ruby2.2 ruby2.2-dev
update-alternatives --set ruby /usr/bin/ruby2.2 >/dev/null 2>&1
update-alternatives --set gem /usr/bin/gem2.2 >/dev/null 2>&1

echo installing Bundler
gem install bundler -N >/dev/null 2>&1

install Git git
install SQLite sqlite3 libsqlite3-dev
install memcached memcached
install Redis redis-server
install RabbitMQ rabbitmq-server

install PostgreSQL postgresql postgresql-contrib libpq-dev
sudo -u postgres createuser --superuser vagrant
sudo -u postgres createdb -O vagrant activerecord_unittest
sudo -u postgres createdb -O vagrant activerecord_unittest2

debconf-set-selections <<< 'mysql-server mysql-server/root_password password root'
debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password root'
install MySQL mysql-server libmysqlclient-dev
mysql -uroot -proot <<SQL
CREATE USER 'rails'@'localhost';
CREATE DATABASE activerecord_unittest  DEFAULT CHARACTER SET utf8 DEFAULT COLLATE utf8_general_ci;
CREATE DATABASE activerecord_unittest2 DEFAULT CHARACTER SET utf8 DEFAULT COLLATE utf8_general_ci;
GRANT ALL PRIVILEGES ON activerecord_unittest.* to 'rails'@'localhost';
GRANT ALL PRIVILEGES ON activerecord_unittest2.* to 'rails'@'localhost';
GRANT ALL PRIVILEGES ON inexistent_activerecord_unittest.* to 'rails'@'localhost';
SQL

install 'Nokogiri dependencies' libxml2 libxml2-dev libxslt1-dev
install 'ExecJS runtime' nodejs

#install rails
sudo add-apt-repository ppa:chris-lea/node.js
sudo apt-get update
sudo apt-get install -y nodejs
gem install rails -v 4.2.0 --no-ri --no-rdoc

# install zsh
sudo apt-get install -y zsh
sudo apt-get install -y git-core
sudo wget https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh -O - | zsh
sudo sh -s `which zsh`
wget https://raw.githubusercontent.com/rastkojokic/dotfiles/master/zshrc -O .zshrc

#gitconfig fetch from dotfiles
wget https://raw.githubusercontent.com/rastkojokic/dotfiles/master/gitconfig -O .gitconfig

#update vim
git clone https://github.com/strika/vimfiles ~/.vim
cd ~/.vim && rake

# Needed for docs generation.
update-locale LANG=en_US.UTF-8 LANGUAGE=en_US.UTF-8 LC_ALL=en_US.UTF-8

echo 'Rails Development Box installed'
