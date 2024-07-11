Usage: ./space_envasion.rb [options]
    -t, --target TARGET              Target URL
    -m, --method METHOD              HTTP method (GET or POST)
    -u, --username USER_VALUE        Username value
    -p, --password PASSWORD_VALUE    Password value
    -U, --users-list FILE            File with list of usernames
    -P, --passwords-list FILE        File with list of passwords
    -e, --error-msg MESSAGE          Authentication error message
    -c, --concurrency NUMBER         Number of concurrent threads
    -s, --stop-on-success            Stop after first successful login
    -h, --help                       Show this help message and exit

===============================================================================================
**1. Basic usage:**
---------------------------------------------------------------------------------------------
./space_envasion.rb -t http://example.com -m GET -u admin -p password -e "Invalid credentials"
---------------------------------------------------------------------------------------------
Executes a single GET request to http://example.com with username admin and password password, expecting the error message "Invalid credentials" in the response.
===============================================================================================
**2.Using POST method:**
---------------------------------------------------------------------------------------------
./space_envasion.rb -t http://example.com/login -m POST -u admin -p password -e "Incorrect login"
---------------------------------------------------------------------------------------------
Executes a POST request to http://example.com/login with username admin and password password, expecting the error message "Incorrect login" in the response.
===============================================================================================
**3.Using usernames and passwords from files:**
---------------------------------------------------------------------------------------------
./space_envasion.rb -t http://example.com -m POST -U users.txt -P passwords.txt -e "Authentication failed"
---------------------------------------------------------------------------------------------
Loads usernames from users.txt and passwords from passwords.txt, attempting to login via POST to http://example.com, and expecting "Authentication failed" in the response for failed attempts.
===============================================================================================
**4.Multiple concurrent threads:**
---------------------------------------------------------------------------------------------
./space_envasion.rb -t http://example.com -m POST -u admin -p password -e "Invalid credentials" -c 20
---------------------------------------------------------------------------------------------
Uses 20 concurrent threads to bruteforce the login with username admin and password password via POST method to http://example.com, checking for "Invalid credentials" error message.
===============================================================================================
**5.Stop on first successful login:**
---------------------------------------------------------------------------------------------
./space_envasion.rb -t http://example.com -m POST -u admin -P passwords.txt -e "Invalid credentials" -s
---------------------------------------------------------------------------------------------
Stops execution upon finding the first successful login combination from admin and any password in passwords.txt, using POST method to http://example.com, and expecting "Invalid credentials" for failed attempts.
===============================================================================================
**6.Help:**
---------------------------------------------------------------------------------------------
./space_envasion.rb -h
---------------------------------------------------------------------------------------------
Displays the help message with all available options and their usage.
===============================================================================================



ETC:
===============================================================================================
ruby space_envasion.rb -t http://example.com/login -m POST -U usernames.txt -P passwords.txt -e "Invalid login" -c 5 --stop-on-success
===============================================================================================
