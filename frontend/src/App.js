import { useEffect, useState, useCallback } from "react";
import "@/App.css";
import { BrowserRouter, Routes, Route } from "react-router-dom";
import axios from "axios";
import { Globe, Search, Users, Activity, Clock, TrendingUp, RefreshCw, ChevronRight, Terminal, Bot, Zap } from "lucide-react";

const BACKEND_URL = process.env.REACT_APP_BACKEND_URL;
const API = `${BACKEND_URL}/api`;

const Dashboard = () => {
  const [stats, setStats] = useState(null);
  const [loading, setLoading] = useState(true);
  const [whoisResult, setWhoisResult] = useState(null);
  const [searchDomain, setSearchDomain] = useState("");
  const [searching, setSearching] = useState(false);
  const [healthStatus, setHealthStatus] = useState(null);

  const fetchStats = useCallback(async () => {
    try {
      const response = await axios.get(`${API}/stats`);
      setStats(response.data);
    } catch (e) {
      console.error("Error fetching stats:", e);
    } finally {
      setLoading(false);
    }
  }, []);

  const fetchHealth = useCallback(async () => {
    try {
      const response = await axios.get(`${API}/health`);
      setHealthStatus(response.data);
    } catch (e) {
      console.error("Error fetching health:", e);
    }
  }, []);

  const searchWhois = async () => {
    if (!searchDomain.trim()) return;
    setSearching(true);
    setWhoisResult(null);
    try {
      const response = await axios.get(`${API}/whois/${searchDomain.trim()}`);
      setWhoisResult(response.data);
    } catch (e) {
      setWhoisResult({ error: true, message: "خطا در دریافت اطلاعات" });
    } finally {
      setSearching(false);
    }
  };

  useEffect(() => {
    fetchStats();
    fetchHealth();
    const interval = setInterval(() => {
      fetchStats();
      fetchHealth();
    }, 30000);
    return () => clearInterval(interval);
  }, [fetchStats, fetchHealth]);

  return (
    <div className="dashboard" data-testid="dashboard">
      {/* Header */}
      <header className="dashboard-header" data-testid="dashboard-header">
        <div className="header-content">
          <div className="logo-section">
            <div className="logo-icon">
              <Globe size={32} />
            </div>
            <div className="logo-text">
              <h1>Whois Bot</h1>
              <span className="logo-subtitle">ربات جستجوی دامنه</span>
            </div>
          </div>
          <div className="header-status">
            <div className={`status-indicator ${healthStatus?.bot_running ? 'active' : 'inactive'}`}>
              <Bot size={18} />
              <span>{healthStatus?.bot_running ? 'Bot Active' : 'Bot Offline'}</span>
            </div>
          </div>
        </div>
      </header>

      {/* Main Content */}
      <main className="dashboard-main">
        {/* Stats Cards */}
        <section className="stats-section" data-testid="stats-section">
          <div className="stats-grid">
            <div className="stat-card" data-testid="stat-total-queries">
              <div className="stat-icon purple">
                <Search size={24} />
              </div>
              <div className="stat-content">
                <span className="stat-value">{loading ? "..." : stats?.total_queries || 0}</span>
                <span className="stat-label">کل جستجوها</span>
              </div>
            </div>

            <div className="stat-card" data-testid="stat-unique-users">
              <div className="stat-icon blue">
                <Users size={24} />
              </div>
              <div className="stat-content">
                <span className="stat-value">{loading ? "..." : stats?.unique_users || 0}</span>
                <span className="stat-label">کاربران یکتا</span>
              </div>
            </div>

            <div className="stat-card" data-testid="stat-bot-status">
              <div className={`stat-icon ${healthStatus?.bot_running ? 'green' : 'red'}`}>
                <Zap size={24} />
              </div>
              <div className="stat-content">
                <span className="stat-value">{healthStatus?.bot_running ? 'فعال' : 'غیرفعال'}</span>
                <span className="stat-label">وضعیت ربات</span>
              </div>
            </div>

            <div className="stat-card" data-testid="stat-popular-domains">
              <div className="stat-icon orange">
                <TrendingUp size={24} />
              </div>
              <div className="stat-content">
                <span className="stat-value">{loading ? "..." : stats?.popular_domains?.length || 0}</span>
                <span className="stat-label">دامنه‌های محبوب</span>
              </div>
            </div>
          </div>
        </section>

        {/* Search Section */}
        <section className="search-section" data-testid="search-section">
          <div className="section-header">
            <Terminal size={20} />
            <h2>جستجوی مستقیم Whois</h2>
          </div>
          <div className="search-box">
            <input
              type="text"
              placeholder="نام دامنه را وارد کنید (مثال: google.com)"
              value={searchDomain}
              onChange={(e) => setSearchDomain(e.target.value)}
              onKeyPress={(e) => e.key === 'Enter' && searchWhois()}
              data-testid="search-input"
            />
            <button 
              onClick={searchWhois} 
              disabled={searching}
              data-testid="search-button"
            >
              {searching ? <RefreshCw className="spin" size={20} /> : <Search size={20} />}
              <span>{searching ? 'در حال جستجو...' : 'جستجو'}</span>
            </button>
          </div>

          {whoisResult && (
            <div className="whois-result" data-testid="whois-result">
              {whoisResult.error ? (
                <div className="result-error">
                  <span>❌ {whoisResult.message}</span>
                </div>
              ) : (
                <div className="result-content">
                  <div className="result-header">
                    <Globe size={20} />
                    <span>{whoisResult.domain_name}</span>
                    <span className={`status-badge ${whoisResult.domain_registered === 'yes' ? 'registered' : 'available'}`}>
                      {whoisResult.domain_registered === 'yes' ? 'ثبت شده' : 'آزاد'}
                    </span>
                  </div>
                  <div className="result-grid">
                    {whoisResult.registrar?.registrar_name && (
                      <div className="result-item">
                        <span className="item-label">ثبت‌کننده</span>
                        <span className="item-value">{whoisResult.registrar.registrar_name}</span>
                      </div>
                    )}
                    {whoisResult.create_date && (
                      <div className="result-item">
                        <span className="item-label">تاریخ ثبت</span>
                        <span className="item-value">{whoisResult.create_date}</span>
                      </div>
                    )}
                    {whoisResult.expiry_date && (
                      <div className="result-item">
                        <span className="item-label">تاریخ انقضا</span>
                        <span className="item-value">{whoisResult.expiry_date}</span>
                      </div>
                    )}
                    {whoisResult.whois_server && (
                      <div className="result-item">
                        <span className="item-label">سرور WHOIS</span>
                        <span className="item-value">{whoisResult.whois_server}</span>
                      </div>
                    )}
                    {whoisResult.name_servers && (
                      <div className="result-item full-width">
                        <span className="item-label">سرورهای DNS</span>
                        <span className="item-value">{whoisResult.name_servers.join(', ')}</span>
                      </div>
                    )}
                  </div>
                </div>
              )}
            </div>
          )}
        </section>

        {/* Two Column Layout */}
        <div className="two-columns">
          {/* Popular Domains */}
          <section className="popular-section" data-testid="popular-section">
            <div className="section-header">
              <TrendingUp size={20} />
              <h2>دامنه‌های محبوب</h2>
            </div>
            <div className="popular-list">
              {loading ? (
                <div className="loading-placeholder">در حال بارگذاری...</div>
              ) : stats?.popular_domains?.length > 0 ? (
                stats.popular_domains.map((item, index) => (
                  <div className="popular-item" key={index} data-testid={`popular-domain-${index}`}>
                    <div className="popular-rank">#{index + 1}</div>
                    <div className="popular-domain">
                      <Globe size={16} />
                      <span>{item.domain}</span>
                    </div>
                    <div className="popular-count">
                      <span>{item.count}</span>
                      <span className="count-label">جستجو</span>
                    </div>
                  </div>
                ))
              ) : (
                <div className="empty-state">هنوز جستجویی انجام نشده</div>
              )}
            </div>
          </section>

          {/* Recent Queries */}
          <section className="recent-section" data-testid="recent-section">
            <div className="section-header">
              <Clock size={20} />
              <h2>جستجوهای اخیر</h2>
            </div>
            <div className="recent-list">
              {loading ? (
                <div className="loading-placeholder">در حال بارگذاری...</div>
              ) : stats?.recent_queries?.length > 0 ? (
                stats.recent_queries.slice(0, 10).map((query, index) => (
                  <div className="recent-item" key={index} data-testid={`recent-query-${index}`}>
                    <div className="recent-icon">
                      <Activity size={16} />
                    </div>
                    <div className="recent-content">
                      <span className="recent-domain">{query.domain}</span>
                      <span className="recent-meta">
                        <span className="recent-command">/{query.command}</span>
                        <span className="recent-user">@{query.username || 'anonymous'}</span>
                      </span>
                    </div>
                    <ChevronRight size={16} className="recent-arrow" />
                  </div>
                ))
              ) : (
                <div className="empty-state">هنوز جستجویی انجام نشده</div>
              )}
            </div>
          </section>
        </div>

        {/* Bot Commands Info */}
        <section className="commands-section" data-testid="commands-section">
          <div className="section-header">
            <Bot size={20} />
            <h2>دستورات ربات تلگرام</h2>
          </div>
          <div className="commands-grid">
            <div className="command-card">
              <code>/start</code>
              <span>شروع کار با ربات</span>
            </div>
            <div className="command-card">
              <code>/whois domain.com</code>
              <span>اطلاعات کامل دامنه</span>
            </div>
            <div className="command-card">
              <code>/check domain.com</code>
              <span>بررسی وضعیت دامنه</span>
            </div>
            <div className="command-card">
              <code>/expiry domain.com</code>
              <span>تاریخ انقضا</span>
            </div>
            <div className="command-card">
              <code>/lang</code>
              <span>تغییر زبان</span>
            </div>
            <div className="command-card">
              <code>/help</code>
              <span>راهنما</span>
            </div>
          </div>
        </section>
      </main>

      {/* Footer */}
      <footer className="dashboard-footer">
        <p>🌐 Whois Domain Lookup Bot • Powered by WhoisFreaks API</p>
      </footer>
    </div>
  );
};

function App() {
  return (
    <div className="App">
      <BrowserRouter>
        <Routes>
          <Route path="/" element={<Dashboard />} />
        </Routes>
      </BrowserRouter>
    </div>
  );
}

export default App;
