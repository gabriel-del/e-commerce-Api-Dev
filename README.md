# Ecommerce BackEnd


## Stack

- Rails 6.0.3.3
- Postgres
- Devise Token Auth for authentication
- Jbuilder for rendering


* [postgresql](https://archlinux.org/packages/?name=postgresql) 
([ArchWiki](https://wiki.archlinux.org/title/PostgreSQL))
* rvm
([ArchWiki](https://wiki.archlinux.org/title/RVM),
[bash](https://rvm.io/rvm/install),
[fish](https://rvm.io/integration/fish),
[digitalocean](https://www.digitalocean.com/community/tutorials/how-to-install-ruby-on-rails-on-arch-linux-with-rvm))

You can also setup [quarry repository](https://wiki.archlinux.org/title/Unofficial_user_repositories#quarry) to use [Yay](https://github.com/Jguer/yay)


## Setup
### Install
* [ruby](https://archlinux.org/packages/?name=ruby)
([ArchWiki](https://wiki.archlinux.org/title/Ruby))
* [ruby-rails](https://aur.archlinux.org/packages/ruby-rails) 
([ArchWiki](https://wiki.archlinux.org/title/Ruby_on_Rails))
* [redis](https://archlinux.org/packages/community/x86_64/redis/)
([ArchWiki](https://wiki.archlinux.org/title/Redis))
* [yarn](https://archlinux.org/packages/community/any/yarn/)
* [ngrok<sup>AUR</sup>](https://aur.archlinux.org/packages/ngrok)
* [ruby-mailcatcher<sup>AUR</sup>](https://aur.archlinux.org/packages/ruby-mailcatcher)
* [postman-bin<sup>AUR</sup>](https://aur.archlinux.org/packages/postman-bin)
(to make tests)
* sidekiq

### Pre-setup
```bash
systemctl start postgres.service
systemctl start redis.service
bundle install
rm .config/credentials/
mailcatcher & # then open 127.0.0.1:1080
ngrok http 3000 &
bundle exec sidekiq -q default -q mailers &
rvm install 2.7.1 && rvm use 2.7.1
```
import ecommerce.postman_collection.json to postman (to make tests)



### Juno
Register (full) on juno.com.br

Then on **Juno**: **Plugins e api** :arrow_right: **criação de credencial** :arrow_right: **habilitar token juno**

Go to **app mobile Juno** :arrow_right: **token juno** :arrow_right: enable

On **Juno**: **Plugins e api** :arrow_right: **criar nova credencial** :arrow_right: set some name, 
ex: *e-commerce-onebitcode* :arrow_right: then put the token on app mobile.

```bash
EDITOR='code --wait' rails credentials:edit --environment development
```

Will open a file, then paste this:

```
juno:
  client: "<client>"
  secret: "<secret>"
  private_token: "<private_token>"
token:
  auth: "<rails_secret>"
  sidekiq: "58190f057d2f49a079406b6a582b765422d7712bc8e"
```

where **<client>** and **<secret>** is on

**Juno**: "Plugins e Api" :arrow_right: **e-commerce-onebitcode**

**<private_token>** is on

**Juno**: **Plugins e Api** :arrow_right: **Token Privado** :arrow_right: **Gerar token privado**

**<rails_secret>**: run '*rails secret*' and take the second part of the last line
The "*sidekiq*" is a random number
then close the file

On **Juno**: **plugins e api** :arrow_right: **notificações de pagamentos**

Paste: **<ngrok_url>**/juno/v1/payment_confirmations?token=**<rails_secret>**

ex: https://fc55-164-163-12-151.ngrok.io/juno/v1/payment_confirmations?token=bc663f5fc219ca6af5f2dfd165d6313b50c30fbfa6226031a09e88642703727f7890cf4e10e01

Where **<ngrok_url>** is found on '*ngrok http 3000*'

### Finish
```bash
rails db:create
rails db:migrate
rails dev:prime
rails s 
```


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


