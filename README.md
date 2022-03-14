# Ecommerce BackEnd


## Stack

- Rails 6.0.3.3
- Postgres
- Devise Token Auth for authentication
- Jbuilder for rendering


* [postgresql](https://archlinux.org/packages/?name=postgresql) 
([ArchWiki](https://wiki.archlinux.org/title/PostgreSQL))
* rvm
([ArchWiki](https://wiki.archlinux.org/title/RVM)
[bash](https://rvm.io/rvm/install)
[fish](https://rvm.io/integration/fish)
[digitalocean](https://www.digitalocean.com/community/tutorials/how-to-install-ruby-on-rails-on-arch-linux-with-rvm))
You can also setup (quarry repository)[https://wiki.archlinux.org/title/Unofficial_user_repositories#quarry] to use [Yay](https://github.com/Jguer/yay)

### Install
* [ruby](https://archlinux.org/packages/?name=ruby)
([ArchWiki](https://wiki.archlinux.org/title/Ruby))
* [ruby-rails](https://aur.archlinux.org/packages/ruby-rails) 
([ArchWiki](https://wiki.archlinux.org/title/Ruby_on_Rails))
* ngrok

* sidekiq
* redis
* yarn
* postman (to tests)
* mailcatcher

### Pre-setup
systemctl start postgres.service
systemctl start redis.service
bundle install
rm .config/credentials/
mailcatcher & # then open 127.0.0.1:1080
ngrok http 3000 &
bundle exec sidekiq -q default -q mailers &
import ecommerce.postman_collection.json pro postman (to tests)
rvm install 2.7.1 && rvm use 2.7.1




### Setup
Register (full) on juno.com.br
Then on Juno: "Plugins e api" -> "criação de credencial" -> "habilitar token juno"
Go to app mobile Juno -> "token juno" -> habilitar
On Juno: "Plugins e api" -> "criar nova credencial" -> set some name, ex: e-commerce-onebitcode -> then put the token on app mobile.


EDITOR='code --wait' rails credentials:edit --environment development
will open a file, then paste this:
juno:
  client: "<client>"
  secret: "<secret>"
  private_token: "<private_token>"
token:
  auth: "<rails_secret>"
  sidekiq: "58190f057d2f49a079406b6a582b765422d7712bc8e"

where <client> and <secret> is on
juno: "Plugins e Api"/e-commerce-onebitcode
<private_token> is on
juno: "Plugins e Api"/"Token Privado"/"Gerar token privado"
<rails_secret> run 'rails secret' and take the second part of the last line
T he"sidekiq" is a random number
then close the file

On Juno: "plugins e api"/"notificações de pagamentos" ->
Paste: <ngrok_url>/juno/v1/payment_confirmations?token=<rails_secret>
ex: https://fc55-164-163-12-151.ngrok.io/juno/v1/payment_confirmations?token=bc663f5fc219ca6af5f2dfd165d6313b50c30fbfa6226031a09e88642703727f7890cf4e10e01
Where <ngrok_url> is found on 'ngrok http 3000'

rails db:create
rails db:migrate
rails dev:prime
rails s 


### Tests
On Postaman
copy all: access-token, client, uid
from: ecommerce/Auth/V1"/user/sign_in"/body:
to: ecommerce/Storefront/V1/Checkouts"/checkouts [boleto]"/body:

rail c:
User.all
User.all.where(profile: 'client')
reload!
Order.last


