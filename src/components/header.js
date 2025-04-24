import { Link } from "gatsby";
import PropTypes from "prop-types";
import React, { useState } from "react";

const Header = ({ siteTitle }) => {
  const [isExpanded, setIsExpanded] = useState(false);
  return (
    <header id="header">
      <h1 className="header-title">
        <Link to="/">{siteTitle}</Link>
      </h1>

      <nav role="navigation">
        <button
          id="nav-toggle"
          type="button"
          aria-expanded={isExpanded}
          aria-controls="nav-list"
          onClick={() => {
            setIsExpanded(!isExpanded);
          }}
        >
          <span aria-hidden="true">☰</span>
          <span className="sr-only">Menu</span>
        </button>
        <ul id="nav-list" className={isExpanded ? "expanded" : undefined}>
          <li className="nav-item">
            <a className="nav-link" href="/about">
              About
            </a>
          </li>
          <li className="nav-item">
            <a className="nav-link" href="/team">
              Team
            </a>
          </li>
          <li className="nav-item">
            <a className="nav-link" href="/federated">
              Federated
            </a>
          </li>
          <li className="nav-item">
            <a className="nav-link" href="/stats">
              Stats
            </a>
          </li>
          <li className="nav-item">
            <a className="nav-link" href="/policies">
              Policies
            </a>
          </li>
          <li className="nav-item">
            <Link className="nav-link" to="/news/">
              Blog
            </Link>
          </li>
          <li className="nav-item">
            <a className="nav-link" href="/contact">
              Contact
            </a>
          </li>
        </ul>
      </nav>
    </header>
  );
};

Header.propTypes = {
  siteTitle: PropTypes.string,
};

Header.defaultProps = {
  siteTitle: undefined,
};

export default Header;
