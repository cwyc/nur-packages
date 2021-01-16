import sys
import os
out = sys.argv[1]
maxLoaded = int(sys.argv[2])
options = sys.argv[3]
modules = sys.argv[4]

if modules == "null":
	os.system(f'npm run start -- generate {options} "*" -o {out}')
elif maxLoaded <= 0:
	os.system(f'npm run start -- generate {options} {modules} -o {out}')
else:
	modules = modules.strip().split();
	while len(modules) > 0:
		grab = min(maxLoaded, len(modules))
		grabbed = " ".join(modules[0:grab])
		modules = modules[grab:]

		os.system(f'npm run start -- generate {options} {grabbed} -o {out}')