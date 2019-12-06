require "json"

source_paths.unshift(File.dirname(__FILE__))

package_json = JSON.parse(File.read("./package.json"))
package_json["browserslist"] = [
  "defaults",
  "not IE 11",
  "not IE_Mob 11"
],

File.write("./package.json", JSON.generate(package_json))