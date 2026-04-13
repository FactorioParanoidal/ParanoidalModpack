#!/usr/bin/env python3
import json
import os
import re
import zipfile

zip_suffix = 'zip'

if __name__ == '__main__':
    with open("info.json") as fin:
        info_json = json.load(fin)
        version = info_json['version']
        zip_prefix = info_json['name']

    version_name = zip_prefix + "_" + version
    zipname = version_name + '.' + zip_suffix
    print("Building %s" % zipname)
    with zipfile.ZipFile(zipname, 'w', zipfile.ZIP_DEFLATED) as zout:
        for root, dirs, files in os.walk('.'):
            if '.git' in dirs:
                dirs.remove('.git')
            for f in files:
                if re.match(zip_prefix + '.*' + zip_suffix, f):
                    continue
                if f.endswith("~"):
                    continue
                fullname = os.path.join(root, f)
                newname = os.path.normpath(os.path.join(version_name, root, f))
                print("%s -> %s" % (fullname, newname))
                zout.write(fullname, arcname=newname)

