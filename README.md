# C--
## TDP019 Projekt: Datorspråk

```C--``` är ett programmeringsspråk som ingen någonsin bör använda. Dess syntax är inspirerad av ```C++``` med vissa inslag från ```Python```. Det är skapat till projektkursen TDP019 med ruby och rdparse. 

### Installation
För att ladda ned och använda språket, följ nedanstående instruktioner. **OBS!** Dessa instruktioner gäller endast för unix baserade system såsom MacOS eller Linux

För att kunna använda ```C--```, måste du först klona ner dess repo. Gör detta med följande kommando:
```Bash
git clone https://gitlab.liu.se/antno464/tdp019.git && cd tdp019
```
Därefter kör du följande kommando för att installera ```C--```:
```Bash
./install.sh
```
Nu är ```C--``` redo att användas. Om du vill ta bort det repo du laddat ned, kör då följande kommando efter installationen (kör inte kommandot om du önskar att behhålla repot på din dator):
```Bash
cd .. && rm -rf tdp019 && cd
```
### Användning
För att använda ```C--``` och exekvera en fil gör på då följande vis:
```Bash
cmm <file_name>.cmm
```
Säkerställ att du använder filändelsen ```.cmm``` på den filen som ska köras.

### Kom igång
Nu när du har installerat ```C--``` är det dags att skriva ditt första program. ```C--``` har en entrypoint i form av en main funktion. Det är enbart koden inuti denna funktion som kommer exekveras så säkerställ att du alltid skriver din kod i den. Main funktionen ska se ut följande:
```C
void codeGoBrrrrrrr(){
    // your code goes here
}
```
Main funktionen är av typen ```void``` och ska därför inte returnera något.


