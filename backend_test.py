#!/usr/bin/env python3
"""
Backend API Testing for Telegram Whois Bot
Tests all API endpoints using the public URL
"""

import requests
import sys
import json
from datetime import datetime
from typing import Dict, Any

class WhoisBotAPITester:
    def __init__(self, base_url="https://domain-whois-bot.preview.emergentagent.com"):
        self.base_url = base_url
        self.api_url = f"{base_url}/api"
        self.tests_run = 0
        self.tests_passed = 0
        self.test_results = []

    def log_test(self, name: str, success: bool, details: Dict[str, Any] = None):
        """Log test result"""
        self.tests_run += 1
        if success:
            self.tests_passed += 1
        
        result = {
            "test_name": name,
            "success": success,
            "timestamp": datetime.now().isoformat(),
            "details": details or {}
        }
        self.test_results.append(result)
        
        status = "✅ PASS" if success else "❌ FAIL"
        print(f"{status} - {name}")
        if details and not success:
            print(f"   Details: {details}")

    def test_health_endpoint(self):
        """Test /api/health endpoint"""
        try:
            response = requests.get(f"{self.api_url}/health", timeout=10)
            
            if response.status_code == 200:
                data = response.json()
                expected_keys = ["status", "bot_running"]
                
                if all(key in data for key in expected_keys):
                    self.log_test("Health Endpoint", True, {
                        "status_code": response.status_code,
                        "response": data,
                        "bot_running": data.get("bot_running")
                    })
                    return True, data
                else:
                    self.log_test("Health Endpoint", False, {
                        "status_code": response.status_code,
                        "error": "Missing expected keys in response",
                        "response": data
                    })
                    return False, data
            else:
                self.log_test("Health Endpoint", False, {
                    "status_code": response.status_code,
                    "error": "Non-200 status code"
                })
                return False, {}
                
        except Exception as e:
            self.log_test("Health Endpoint", False, {
                "error": str(e),
                "type": "connection_error"
            })
            return False, {}

    def test_stats_endpoint(self):
        """Test /api/stats endpoint"""
        try:
            response = requests.get(f"{self.api_url}/stats", timeout=15)
            
            if response.status_code == 200:
                data = response.json()
                expected_keys = ["total_queries", "unique_users", "popular_domains", "recent_queries"]
                
                if all(key in data for key in expected_keys):
                    self.log_test("Stats Endpoint", True, {
                        "status_code": response.status_code,
                        "total_queries": data.get("total_queries"),
                        "unique_users": data.get("unique_users"),
                        "popular_domains_count": len(data.get("popular_domains", [])),
                        "recent_queries_count": len(data.get("recent_queries", []))
                    })
                    return True, data
                else:
                    self.log_test("Stats Endpoint", False, {
                        "status_code": response.status_code,
                        "error": "Missing expected keys in response",
                        "response": data
                    })
                    return False, data
            else:
                self.log_test("Stats Endpoint", False, {
                    "status_code": response.status_code,
                    "error": "Non-200 status code"
                })
                return False, {}
                
        except Exception as e:
            self.log_test("Stats Endpoint", False, {
                "error": str(e),
                "type": "connection_error"
            })
            return False, {}

    def test_whois_endpoint(self, domain="google.com"):
        """Test /api/whois/{domain} endpoint"""
        try:
            response = requests.get(f"{self.api_url}/whois/{domain}", timeout=30)
            
            if response.status_code == 200:
                data = response.json()
                
                # Check for essential WHOIS data fields
                if data and isinstance(data, dict):
                    # Check if we got actual WHOIS data
                    has_domain_info = any(key in data for key in [
                        'domain_name', 'domain_registered', 'registrar', 
                        'create_date', 'expiry_date', 'whois_server'
                    ])
                    
                    if has_domain_info:
                        self.log_test(f"WHOIS Endpoint ({domain})", True, {
                            "status_code": response.status_code,
                            "domain_name": data.get("domain_name"),
                            "domain_registered": data.get("domain_registered"),
                            "registrar": data.get("registrar", {}).get("registrar_name") if isinstance(data.get("registrar"), dict) else data.get("registrar"),
                            "has_expiry_date": bool(data.get("expiry_date")),
                            "has_whois_server": bool(data.get("whois_server"))
                        })
                        return True, data
                    else:
                        self.log_test(f"WHOIS Endpoint ({domain})", False, {
                            "status_code": response.status_code,
                            "error": "Response doesn't contain expected WHOIS data",
                            "response_keys": list(data.keys()) if isinstance(data, dict) else "Not a dict"
                        })
                        return False, data
                else:
                    self.log_test(f"WHOIS Endpoint ({domain})", False, {
                        "status_code": response.status_code,
                        "error": "Empty or invalid response data",
                        "response": data
                    })
                    return False, data
            else:
                self.log_test(f"WHOIS Endpoint ({domain})", False, {
                    "status_code": response.status_code,
                    "error": "Non-200 status code",
                    "response_text": response.text[:200] if response.text else "No response text"
                })
                return False, {}
                
        except Exception as e:
            self.log_test(f"WHOIS Endpoint ({domain})", False, {
                "error": str(e),
                "type": "connection_error"
            })
            return False, {}

    def test_root_endpoint(self):
        """Test /api/ root endpoint"""
        try:
            response = requests.get(f"{self.api_url}/", timeout=10)
            
            if response.status_code == 200:
                data = response.json()
                if "message" in data:
                    self.log_test("Root API Endpoint", True, {
                        "status_code": response.status_code,
                        "message": data.get("message")
                    })
                    return True, data
                else:
                    self.log_test("Root API Endpoint", False, {
                        "status_code": response.status_code,
                        "error": "Missing message in response"
                    })
                    return False, data
            else:
                self.log_test("Root API Endpoint", False, {
                    "status_code": response.status_code,
                    "error": "Non-200 status code"
                })
                return False, {}
                
        except Exception as e:
            self.log_test("Root API Endpoint", False, {
                "error": str(e),
                "type": "connection_error"
            })
            return False, {}

    def run_all_tests(self):
        """Run all API tests"""
        print(f"🚀 Starting API tests for: {self.base_url}")
        print("=" * 60)
        
        # Test basic connectivity first
        health_success, health_data = self.test_health_endpoint()
        
        # Test root endpoint
        self.test_root_endpoint()
        
        # Test stats endpoint
        stats_success, stats_data = self.test_stats_endpoint()
        
        # Test WHOIS endpoint with google.com
        whois_success, whois_data = self.test_whois_endpoint("google.com")
        
        # Test WHOIS endpoint with another domain
        self.test_whois_endpoint("github.com")
        
        print("=" * 60)
        print(f"📊 Test Results: {self.tests_passed}/{self.tests_run} passed")
        
        # Check critical functionality
        critical_tests = ["Health Endpoint", "Stats Endpoint", "WHOIS Endpoint (google.com)"]
        critical_passed = sum(1 for result in self.test_results 
                            if result["test_name"] in critical_tests and result["success"])
        
        if critical_passed == len(critical_tests):
            print("✅ All critical API endpoints are working!")
            return True
        else:
            print(f"❌ {len(critical_tests) - critical_passed} critical endpoints failed!")
            return False

    def get_summary(self):
        """Get test summary"""
        return {
            "total_tests": self.tests_run,
            "passed_tests": self.tests_passed,
            "failed_tests": self.tests_run - self.tests_passed,
            "success_rate": (self.tests_passed / self.tests_run * 100) if self.tests_run > 0 else 0,
            "test_results": self.test_results
        }

def main():
    """Main test execution"""
    tester = WhoisBotAPITester()
    
    try:
        success = tester.run_all_tests()
        summary = tester.get_summary()
        
        # Save detailed results
        with open("/app/backend_test_results.json", "w") as f:
            json.dump(summary, f, indent=2)
        
        print(f"\n📄 Detailed results saved to: /app/backend_test_results.json")
        
        return 0 if success else 1
        
    except KeyboardInterrupt:
        print("\n⚠️ Tests interrupted by user")
        return 1
    except Exception as e:
        print(f"\n💥 Unexpected error: {e}")
        return 1

if __name__ == "__main__":
    sys.exit(main())