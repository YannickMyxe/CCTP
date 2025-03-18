local portimus = require "/programs/cctp/portimus/prime" or error("Cannot find portimus library.")

portimus.setup()
portimus.open(1)
portimus.printOpenports()
