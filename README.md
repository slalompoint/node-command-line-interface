Node Command Line Interface
===


DESCRIPTION
---

Supporting source code to accompany the blog post: http://www.slalompoint.com/node-command-line-interface-p2/

Code is provided as a learning material and I highly recommend that you modify the code to the requirements of your app. 

Usage
---

### Installation
    ./app.sh install

### Run 
    ./app.sh run
    
### Change port (port 1337)
    ./app.sh run -p 1337

### Run in debug mode (currently a bit patchy)
    ./app.sh debug
Then point to http://localhost:8080/ in a webkit browser

### Test running:

#### Run all tests:
    ./presenter runtests
    
#### Run a single test:
    ./presenter runtests tests/unit/app.js
    
### Show help
    ./presenter -h

