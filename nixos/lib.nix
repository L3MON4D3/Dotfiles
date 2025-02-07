{
  assertSecret = sname: ''
    if [ ! -f /var/secrets/${sname} ]; then
      echo ASSERT FAILED: Secret ${sname} is missing!
      exit 1
    fi
  '';
  secret = (sname: "/var/secrets/${sname}");
}
