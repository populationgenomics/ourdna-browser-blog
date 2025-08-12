import { Link } from "gatsby";
import PropTypes from "prop-types";
import React, { useCallback, useState } from "react";
import styled from 'styled-components';
import logoImage from './OurDNA_Browser_Header.png';


const LogoWrapper = styled.div`
  @media (max-width: 900px) {
    display: flex;
    flex-direction: row;
    justify-content: space-between;
    align-items: center;
    width: 100%;
    margin-bottom: 5px;
  }
`

const Logo = styled.div`
  color: white;
  font-size: 1.5em;
  font-weight: bold;
`

const Header = ({ siteTitle }) => {
  const [isExpanded, setIsExpanded] = useState(false);

  const toggleMenu = useCallback(() => {
    setIsExpanded((previousValue) => !previousValue)
  }, [])
  const closeMenu = useCallback(() => {
    setIsExpanded(false)
  }, []);

  return (
    <header id="header">

      <h1 className="header-title">
        <LogoWrapper>
          <Link to="/" onClick={closeMenu}>
            <Logo>
              <svg width="50" viewBox="0 0 341 228">
                <image href={logoImage} />
              </svg>
            </Logo>
          </Link>
        </LogoWrapper>
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
