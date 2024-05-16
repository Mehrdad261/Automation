# We had many networks, and one of our jobs was to search for available IP addresses for new users because we didn't use DHCP. I wrote this program to check for any available IP addresses within our domain ranges
import ipaddress
import ping3
import time
import sys

def check_availability(ip_address):
    try:
        # this line check is the ip address is correct or no
        ip_address = ipaddress.ip_address(ip_address)
    except ValueError:
        print('Invalid IP address format.')
        return False

    # Define 20, 10, 50 or any other network ranges and the 3rd and 4th Octet enter by user
    network_ranges = [
        ipaddress.ip_network('20.1.0.0/16'),
        ipaddress.ip_network('10.1.0.0/16')
        #....
    ]

    # Check if the IP address is in any of the valid network ranges (10 and 20 network)
    in_range = False
    for network in network_ranges:
        if ip_address in network:
            in_range = True
            break

    if not in_range:
        print('The IP address is not in any of the valid network ranges.')
        return False

    # Check if the IP address responds to a ping
    if ping3.ping(str(ip_address)):
        print('The IP address already used.')
        return False

    print('The IP address is available.')
    return True

def main():
    while True:
        ip_address = input("Enter IP address to check fro availability in 20 or 10 network): ")
        if check_availability(ip_address):
            break

if __name__ == "__main__":
    main()
time.sleep(1)
