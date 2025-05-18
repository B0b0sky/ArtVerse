# ArtVerse

A decentralized art marketplace and exhibition platform where digital artworks can be featured across multiple galleries.

## Overview

ArtVerse is a Clarity smart contract that enables a decentralized art ecosystem on the Stacks blockchain. It allows artists to mint digital artworks as NFTs, galleries to curate exhibitions, and collectors to own and transfer these unique digital assets.

## Features

- **NFT Artwork Management**: Mint, transfer, and track ownership of digital artworks
- **Gallery Registration**: Galleries can register to be part of the ArtVerse ecosystem
- **Exhibition Curation**: Galleries can feature artworks with customizable prominence scores
- **Artwork Properties**: Store and retrieve metadata and properties for artworks
- **Access Controls**: Proper authorization checks for all sensitive operations

## Contract Functions

### Admin Functions

- `set-contract-owner`: Update the contract owner
- `register-gallery`: Register a new gallery to the platform
- `deactivate-gallery`: Deactivate a previously registered gallery

### NFT Functions

- `mint-artwork`: Create a new NFT artwork with metadata
- `transfer-artwork`: Transfer an artwork to another user
- `set-artwork-curation`: Define how an artwork is featured in a specific gallery
- `set-artwork-properties`: Set or update an artwork's properties

### Read-Only Functions

- `get-artwork-details`: Get basic information about an artwork
- `get-artwork-properties`: Get the properties of an artwork
- `get-artwork-curation`: Check how an artwork is featured in a specific gallery
- `get-gallery-info`: Get information about a registered gallery
- `get-artwork-owner`: Get the current owner of an artwork
- `is-gallery-active`: Check if a gallery is currently active

## Usage

### For Artists and Galleries

1. Galleries register using `register-gallery`
2. Artists or galleries mint artworks using `mint-artwork`
3. Galleries curate exhibitions by setting artwork prominence using `set-artwork-curation`

### For Collectors

1. Acquire ArtVerse NFT artworks through minting or transfers
2. View featured artworks across different galleries in the ecosystem
3. Transfer artworks to other collectors as needed

## Development

This contract is developed using Clarity and can be tested with Clarinet.