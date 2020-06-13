##
# Allow security researchers to contact us if they find an issue in the
# application. See https://securitytxt.org/
create_file "public/.well-known/security.txt" do
  <<~EO_CONTENT
    Contact: security@ackama.com
    Preferred-Languages: en
  EO_CONTENT
end
