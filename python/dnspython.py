http://www.dnspython.org

wget http://www.dnspython.org/kits/1.15.0/dnspython-1.15.0.tar.gz
tar zxvf dnspython-1.15.0.tar.gz
cd dnsdnspython-1.15.0
python setup.py install

Get the MX target and preference of a name:


    import dns.resolver

    answers = dns.resolver.query('dnspython.org', 'MX')
    for rdata in answers:
        print 'Host', rdata.exchange, 'has preference', rdata.preference
    	      

Transfer a zone from a server and print it with the names sorted in DNSSEC order:


    import dns.query
    import dns.zone

    z = dns.zone.from_xfr(dns.query.xfr('204.152.189.147', 'dnspython.org'))
    names = z.nodes.keys()
    names.sort()
    for n in names:
        print z[n].to_text(n)
    	      

Use DNS dynamic update to set the address of a host to a value specified on the command line:


    import dns.query
    import dns.tsigkeyring
    import dns.update
    import sys

    keyring = dns.tsigkeyring.from_text({
        'host-example.' : 'XXXXXXXXXXXXXXXXXXXXXX=='
    })

    update = dns.update.Update('dyn.test.example', keyring=keyring)
    update.replace('host', 300, 'a', sys.argv[1])

    response = dns.query.tcp(update, '10.0.0.1')
    	      

Manipulate domain names:


    import dns.name

    n = dns.name.from_text('www.dnspython.org')
    o = dns.name.from_text('dnspython.org')
    print n.is_subdomain(o)         # True
    print n.is_superdomain(o)       # False
    print n > o                     # True
    rel = n.relativize(o)           # rel is the relative name 'www'
    n2 = rel + o
    print n2 == n                   # True
    print n.labels                  # ('www', 'dnspython', 'org', '')
    	      

Generate reverse mapping information


    # Usage: reverse.py ...
    #
    # This demo script will load in all of the zones specified by the
    # filenames on the command line, find all the A RRs in them, and
    # construct a reverse mapping table that maps each IP address used to
    # the list of names mapping to that address.  The table is then sorted
    # nicely and printed.
    #
    # Note!  The zone name is taken from the basename of the filename, so
    # you must use filenames like "/wherever/you/like/dnspython.org" and
    # not something like "/wherever/you/like/foo.db" (unless you're
    # working with the ".db" GTLD, of course :)).
    #
    # If this weren't a demo script, there'd be a way of specifying the
    # origin for each zone instead of constructing it from the filename.

    import dns.zone
    import dns.ipv4
    import os.path
    import sys

    reverse_map = {}

    for filename in sys.argv[1:]:
        zone = dns.zone.from_file(filename, os.path.basename(filename),
                                  relativize=False)
        for (name, ttl, rdata) in zone.iterate_rdatas('A'):
            l = reverse_map.get(rdata.address)
            if l is None:
                l = []
                reverse_map[rdata.address] = l
            l.append(name)

    keys = reverse_map.keys()
    keys.sort(lambda a1, a2: cmp(dns.ipv4.inet_aton(a1), dns.ipv4.inet_aton(a2)))
    for k in keys:
        v = reverse_map[k]
        v.sort()
        l = map(str, v)     # convert names to strings for prettier output
        print k, l
    	      

Convert IPv4 and IPv6 addresses to/from their corresponding DNS reverse map names:


    import dns.reversename
    n = dns.reversename.from_address("127.0.0.1")
    print n
    print dns.reversename.to_address(n)
    	      

Convert E.164 numbers to/from their corresponding ENUM names:


    import dns.e164
    n = dns.e164.from_e164("+1 555 1212")
    print n
    print dns.e164.to_e164(n)
    	      

