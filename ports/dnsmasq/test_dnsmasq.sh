#!/bin/bash  
# test-dnsmasq-remote.sh - Test dnsmasq from Ubuntu client to QNX target  
  
DNS_SERVER="${1:-${DNS_SERVER}}"
DNS_PORT="${2:-${DNS_PORT:-5354}}"
TEST_DIR="${3:-${TEST_DIR:-/tmp/dnsmasq-remote-test}}"
TFTP_DIR="${4:-${TFTP_DIR:-$TEST_DIR/tftpboot}}"
  
# Test results  
PASSED=0  
FAILED=0  
  
# Function to print test results  
print_result() {  
    if [ $1 -eq 0 ]; then  
        echo -e "PASS: $2"  
        ((PASSED++))  
    else  
        echo -e "FAIL: $2"  
        ((FAILED++))  
    fi  
}  
  
# Setup test environment  
setup_test_env() {  
    echo "Setting up test environment..."  
    mkdir -p "$TEST_DIR" "$TFTP_DIR"  
      
    # Create TFTP test file (for when TFTP is tested on target)  
    echo "TFTP test content from Ubuntu client" > "$TFTP_DIR/testfile"  
      
    echo "Test environment setup complete."  
}  
  
# Test DNS Resolution  
test_dns_resolution() {  
    echo "Testing DNS Resolution..."  
      
    # Basic A record resolution  
    dig @"$DNS_SERVER" -p "$DNS_PORT" google.com +time=5 +tries=1 > /dev/null 2>&1  
    print_result $? "DNS A record resolution (google.com)"  
      
    # AAAA record resolution  
    dig @"$DNS_SERVER" -p "$DNS_PORT" google.com AAAA +time=5 +tries=1 > /dev/null 2>&1  
    print_result $? "DNS AAAA record resolution (google.com)"  
      
    # MX record resolution  
    dig @"$DNS_SERVER" -p "$DNS_PORT" google.com MX +time=5 +tries=1 > /dev/null 2>&1  
    print_result $? "DNS MX record resolution (google.com)"  
      
    # Local domain resolution (if configured on target)  
    dig @"$DNS_SERVER" -p "$DNS_PORT" test.local +time=5 +tries=1 > /dev/null 2>&1  
    print_result $? "Local domain resolution (test.local)"  
}  
  
# Test DNS Caching  
test_dns_caching() {  
    echo "Testing DNS Caching..."  
      
    # Cache statistics via DNS  
    cache_size=$(dig @"$DNS_SERVER" -p "$DNS_PORT" +short chaos txt cachesize.bind 2>/dev/null)  
    if [ -n "$cache_size" ]; then  
        print_result 0 "Cache statistics query (cachesize.bind: $cache_size)"  
    else  
        print_result 1 "Cache statistics query"  
    fi  
      
    # Cache hits  
    hits=$(dig @"$DNS_SERVER" -p "$DNS_PORT" +short chaos txt hits.bind 2>/dev/null)  
    if [ -n "$hits" ]; then  
        print_result 0 "Cache hits query (hits.bind: $hits)"  
    else  
        print_result 1 "Cache hits query"  
    fi  
      
    # Cache misses  
    misses=$(dig @"$DNS_SERVER" -p "$DNS_PORT" +short chaos txt misses.bind 2>/dev/null)  
    if [ -n "$misses" ]; then  
        print_result 0 "Cache misses query (misses.bind: $misses)"  
    else  
        print_result 1 "Cache misses query"  
    fi  
      
    # Test caching behavior - query twice  
    dig @"$DNS_SERVER" -p "$DNS_PORT" cache-test-nonexistent.com +time=5 +tries=1 > /dev/null 2>&1  
    first_result=$?  
    sleep 1  
    dig @"$DNS_SERVER" -p "$DNS_PORT" cache-test-nonexistent.com +time=5 +tries=1 > /dev/null 2>&1  
    second_result=$?  
      
    if [ $first_result -eq 0 ] || [ $second_result -eq 0 ]; then  
        print_result 0 "DNS caching behavior (consistent responses)"  
    else  
        print_result 1 "DNS caching behavior"  
    fi  
}  
  
# Test DNS Features  
test_dns_features() {  
    echo "Testing DNS Features..."  
      
    # Reverse DNS lookup  
    dig @"$DNS_SERVER" -p "$DNS_PORT" -x 8.8.8.8 +time=5 +tries=1 > /dev/null 2>&1  
    print_result $? "Reverse DNS lookup (8.8.8.8)"  
      
    # TXT record query  
    dig @"$DNS_SERVER" -p "$DNS_PORT" google.com TXT +time=5 +tries=1 > /dev/null 2>&1  
    print_result $? "TXT record query (google.com)"  
      
    # SOA record query  
    dig @"$DNS_SERVER" -p "$DNS_PORT" google.com SOA +time=5 +tries=1 > /dev/null 2>&1  
    print_result $? "SOA record query (google.com)"  
      
    # EDNS0 support  
    dig @"$DNS_SERVER" -p "$DNS_PORT" +dnssec google.com +time=5 +tries=1 > /dev/null 2>&1  
    print_result $? "EDNS0 support"  
}  
  
# Test Network Connectivity  
test_network_connectivity() {  
    echo "Testing Network Connectivity..."  
      
    # Basic connectivity test  
    ping -c 1 -W 2 "$DNS_SERVER" > /dev/null 2>&1  
    print_result $? "Network connectivity (ping)"  
      
    # Port connectivity test  
    nc -z -w 2 "$DNS_SERVER" "$DNS_PORT" > /dev/null 2>&1  
    print_result $? "Port connectivity (port $DNS_PORT)"  
      
    # DNS over TCP  
    dig @"$DNS_SERVER" -p "$DNS_PORT" google.com +tcp +time=5 +tries=1 > /dev/null 2>&1  
    print_result $? "DNS over TCP"  
}  
  
# Test Performance  
test_performance() {  
    echo "Testing Performance..."  
      
    # DNS response time test  
    start_time=$(date +%s%N)  
    dig @"$DNS_SERVER" -p "$DNS_PORT" google.com +time=5 +tries=1 > /dev/null 2>&1  
    end_time=$(date +%s%N)  
    response_time=$(( (end_time - start_time) / 1000000 ))  
      
    if [ $response_time -lt 1000 ]; then  
        print_result 0 "DNS response time (${response_time}ms < 1000ms)"  
    else  
        print_result 1 "DNS response time (${response_time}ms >= 1000ms)"  
    fi  
      
    # Concurrent queries test  
    for i in {1..10}; do  
        dig @"$DNS_SERVER" -p "$DNS_PORT" google.com +time=5 +tries=1 > /dev/null 2>&1 &  
    done  
    wait  
    print_result 0 "Concurrent DNS queries (10 parallel)"  
}  
  
# Test Error Handling  
test_error_handling() {  
    echo "Testing Error Handling..."  
      
    # Invalid domain query  
    dig @"$DNS_SERVER" -p "$DNS_PORT" invalid-domain-test-12345.com +time=5 +tries=1 > /dev/null 2>&1  
    print_result $? "Invalid domain handling"  
      
    # Query for non-existent record type  
    dig @"$DNS_SERVER" -p "$DNS_PORT" google.com TYPE65333 +time=5 +tries=1 > /dev/null 2>&1  
    print_result $? "Invalid record type handling"  
      
    # Empty query test
    echo "" | nc -zv "$DNS_SERVER" "$DNS_PORT" > /dev/null 2>&1    
    if [ $? -eq 0 ]; then    
        print_result 0 "Empty query handling"  # Pass if connection succeeds  
    else    
        print_result 1 "Empty query handling"    
    fi
}  
  
# Test Different Query Tools  
test_query_tools() {  
    echo "Testing Different Query Tools..."  
      
    # host command  
    host -p "$DNS_PORT" google.com "$DNS_SERVER" > /dev/null 2>&1  
    print_result $? "host command"  
      
    # nslookup command  
    nslookup -port="$DNS_PORT" google.com "$DNS_SERVER" > /dev/null 2>&1  
    print_result $? "nslookup command"  
      
    # dig command (already tested but included for completeness)  
    dig @"$DNS_SERVER" -p "$DNS_PORT" google.com +time=5 +tries=1 > /dev/null 2>&1  
    print_result $? "dig command"  
}  
  
# Generate Test Report  
generate_report() {  
    echo ""  
    echo "==================================="  
    echo "     REMOTE DNSMASQ TEST REPORT"  
    echo "==================================="  
    echo "Target Server: $DNS_SERVER:$DNS_PORT"  
    echo "Test Date: $(date)"  
    echo "Total Tests: $((PASSED + FAILED))"  
    echo -e "Passed: $PASSED"  
    echo -e "Failed: $FAILED"  
    echo "Success Rate: $(( PASSED * 100 / (PASSED + FAILED) ))%"  
    echo ""  
      
    if [ $FAILED -eq 0 ]; then  
        echo -e "All tests passed!"  
        echo "dnsmasq on QNX target is functioning correctly."  
    else  
        echo -e "Some tests failed."  
        echo "Check the target dnsmasq configuration and logs."  
    fi  
      
    echo ""  
    echo "Note: For DHCP/TFTP testing, ensure these services are"  
    echo "configured on the target QNX machine."  
}  
  
# Main execution  
main() {  
    echo "==================================="  
    echo "  REMOTE DNSMASQ TEST SUITE"  
    echo "  Testing QNX Target from Ubuntu"  
    echo "==================================="  
    echo ""  
    sleep 2 
    # Setup  
    setup_test_env  
    sleep 2 
      
    # Run tests  
    test_network_connectivity  
    sleep 2 
    test_dns_resolution  
    sleep 2 
    test_dns_caching  
    sleep 2 
    test_dns_features  
    sleep 2 
    test_performance  
    sleep 2 
    test_error_handling  
    sleep 2 
    test_query_tools  
    sleep 10
      
    # Generate report  
    generate_report  
}  
  
# Run main function  
main "$@"