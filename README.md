
![Alt](https://www.onlinemarkedspladser.dk/wp-content/uploads/2018/04/Logo-OM.png "Onlinemarkedspladser")

## Formål
> Danske virksomheder skal være bedre til at drive eksportsalg via digitale kanaler. Ifølge Danmarks Statistik udgjorde danske virksomheders samlede omsætning via web-salg til udlandet blot 2%, hvilket placerer Danmark på en 26. plads i Europa. Online markedspladser forventes at blive en vigtig salgskanal i fremtiden og det er derfor vigtigt, at danske virksomheder får kvalificeret viden om disse og værktøjer/metoder, så de kan træffe en forretningsmæssig beslutning om, hvorvidt de ønsker anvende disse.

> Projektets formål er derfor:

> * at ruste danske virksomheder med viden og kompetence til at træffe kvalificeret beslutning om, hvorvidt de ønsker at drive salg via online markedspladser
> * at tilvejebringe værktøjer/metoder, så virksomhederne lettere kan sælge via online markedspladser

Læs mere [link](https://www.onlinemarkedspladser.dk/om-projektet "her").

## Arkitektur
Dette repository indeholder al kode, som skal bruges til at sætte et system op, som kan facilitere udveksling af data imellem GOMP's og ERP systemer. Systemet er bygget op omkring micro service arkitektur og er skrevet primært i ruby og Ruby on Rails. 
### Core API
Som bindeled mellem integrationerne til GOMP/ERP systemerne og GUI bruges der et et Core API (arctic-core). Her håndteres data storage og udvekslingen af dataen mellem de forskellige services. Der bruges Postgres (primær datastore) og Redis (køsystem).
Der er følgende dependencies:
```
Postgresql >= 10.5
Ruby 2.5.1
Memcached
Redis
npm >= 5.8
```
Der kan nemt opsættes `./bin/setup` derefter kan du starte applikationen med `bundle exec foreman start -f Procfile.dev`

### Backoffice
Som GUI bruges merchant-backoffice, som er en node applikation skrevet i primært VUE. Her skal også køres oauth_client_app som er en simpel node app der håndterer OAuth authentication til backoffice. Denne køres med `node index.js`

### Integrationer
Systemet indeholder services som kommunikerer påtværs via Core API. Disse service-integrationer skal deployes til deres egne servere. De kører via Sidekiq og er simple ruby scripts der køres.

## Opsætning
Du er selv ansvarlig for drift og deraf opsætningen af deployment til servere. Der anbefales at bruges en mindre UNIX server (500-1000 mb RAM) til hosting af hver komponent og en lidt større til hosting af database og CORE API.
Opsætningen skulle være lige til, men kræver naturligvis, at Capistrano opsættes korrekt til at pege på dine servere. 
### Bemærk
Under udviklingen har der været anvendt  CircleCI, men konfigurationfilerne er fjernet grundet følsomme-oplysninger var deri. Derudover er der også fjernet andre filer indeholdende følsomme IPer eller referencer til brugere osv.


## Licens
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
