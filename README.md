# Urban Garden Collective

A blockchain-based urban agriculture network with community land use rights protection, built on the Stacks blockchain using Clarity smart contracts.

## Overview

The Urban Garden Collective empowers urban communities to establish, manage, and protect community gardens and urban farming spaces through decentralized governance and blockchain-secured land use rights. This system creates transparent plot allocation, protects growing rights, and ensures equitable access to urban agriculture opportunities.

## Mission

- **Food Sovereignty**: Enable communities to control their local food production systems
- **Land Use Rights**: Protect community access to urban growing spaces
- **Equitable Access**: Ensure fair distribution of gardening plots and resources
- **Community Empowerment**: Foster local self-reliance through urban agriculture
- **Sustainable Cities**: Promote green infrastructure and environmental resilience

## Core Features

### Urban Plot Registry
- **Plot Documentation**: Comprehensive records of community garden plots and growing spaces
- **Land Use Tracking**: Immutable history of plot allocation, usage, and stewardship
- **Geographic Mapping**: Location-based plot identification and boundary documentation
- **Resource Management**: Tracking of water access, soil quality, and infrastructure
- **Community Governance**: Democratic plot allocation and rule enforcement

### Growing Rights Protocol
- **Access Rights**: Community-controlled permissions for urban agriculture participation
- **Food Sovereignty**: Protection of local food production and distribution rights
- **Plot Allocation**: Fair and transparent assignment of growing spaces
- **Resource Sharing**: Community tools, water, and infrastructure management
- **Dispute Resolution**: Decentralized arbitration for land use conflicts

## Technical Architecture

### Smart Contracts

1. **urban-plot-registry.clar**
   - Manages community garden plots and urban farming space documentation
   - Stores immutable records of plot boundaries, usage, and stewardship
   - Provides query interfaces for plot availability and community planning

2. **growing-rights-protocol.clar**
   - Enforces urban agriculture access and food sovereignty rights
   - Manages community member permissions and plot allocations
   - Implements resource sharing and dispute resolution mechanisms

### Data Structures

- **Garden Communities**: Urban agriculture collectives with governance structures
- **Plot Records**: Detailed plot information including location, size, and conditions
- **Member Profiles**: Community participants with growing experience and contributions
- **Resource Allocations**: Water rights, tool access, and infrastructure sharing
- **Governance Systems**: Democratic decision-making and community rules

## Benefits

### For Urban Communities
- **Food Security**: Local food production reducing external dependencies
- **Community Building**: Shared spaces fostering social connections and collaboration
- **Economic Empowerment**: Reduced food costs and potential income from surplus
- **Environmental Benefits**: Green spaces improving air quality and urban ecology

### For Individual Gardeners
- **Guaranteed Access**: Secure plot rights protected by blockchain technology
- **Resource Sharing**: Access to communal tools, water systems, and knowledge
- **Community Support**: Mentorship, skill sharing, and collaborative growing
- **Food Production**: Fresh, healthy produce for personal consumption

### For City Planning
- **Green Infrastructure**: Urban agriculture contributing to sustainable city development
- **Community Engagement**: Resident participation in neighborhood improvement
- **Land Use Optimization**: Productive use of vacant lots and underutilized spaces
- **Climate Resilience**: Urban farming supporting environmental adaptation strategies

### For Food Justice
- **Equitable Access**: Democratic allocation ensuring diverse community participation
- **Cultural Preservation**: Support for traditional and culturally significant crops
- **Education**: Knowledge sharing about sustainable growing practices
- **Health Outcomes**: Improved nutrition and food access in underserved areas

## Use Cases

### Community Garden Establishment
- Register new urban agriculture sites with plot boundaries and rules
- Allocate individual plots to community members through democratic processes
- Track resource needs including water access, soil amendments, and infrastructure
- Document community agreements and governance structures

### Growing Rights Management
- Manage member registration and plot assignment processes
- Enforce community rules regarding plot maintenance and participation
- Facilitate resource sharing including tools, seeds, and harvesting equipment
- Resolve disputes over plot boundaries, usage, or community participation

### Resource Coordination
- Coordinate shared infrastructure including water systems and storage
- Manage community tool libraries and equipment sharing
- Track communal expenses and resource contributions
- Plan seasonal activities and community events

### Knowledge Sharing
- Document successful growing practices and crop varieties
- Share information about pest management and organic techniques
- Coordinate educational workshops and skill-building sessions
- Connect experienced gardeners with newcomers

## Getting Started

### Prerequisites
- Stacks wallet for blockchain interactions
- Community membership or plot allocation
- Basic understanding of urban gardening principles
- Commitment to community participation and collaboration

### Installation
```bash
git clone https://github.com/abdulmalikabdullahi678-sys/Urban-Garden-Collective.git
cd Urban-Garden-Collective
npm install
```

### Development
```bash
clarinet check
clarinet test
clarinet console
```

## Usage Examples

### Register Community Garden
```clarity
(contract-call? .urban-plot-registry register-garden
  "Sunset Community Garden"
  "Urban farming collective in Sunset District"
  u50  ; 50 available plots
  "community-managed"
  "37.7749,-122.4194")  ; GPS coordinates
```

### Allocate Growing Plot
```clarity
(contract-call? .growing-rights-protocol allocate-plot
  'ST1FARMER123...
  u1  ; garden-id
  u25  ; plot-number
  u500  ; plot size in sq ft
  "vegetables-herbs")
```

### Register Community Member
```clarity
(contract-call? .growing-rights-protocol register-member
  "Jane Gardener"
  "5 years urban farming experience"
  "vegetables-composting-education")
```

## Governance

The Urban Garden Collective operates under community-driven governance principles:

- **Democratic Decision-Making**: Community members vote on plot allocation and rules
- **Consensus Building**: Major changes require broad community support
- **Transparent Operations**: All governance actions recorded on-chain
- **Inclusive Participation**: Open membership encouraging diverse community involvement
- **Local Autonomy**: Each garden community maintains self-governance within framework

## Legal Framework

This system operates within existing zoning and land use regulations while advocating for:

- Recognition of urban agriculture as essential infrastructure
- Protection of community land use rights and long-term access
- Support for local food production and distribution systems
- Fair allocation of public and private land for community growing

## Environmental Impact

### Sustainability Benefits
- **Carbon Sequestration**: Urban growing spaces capturing atmospheric CO2
- **Stormwater Management**: Garden plots reducing urban runoff and flooding
- **Biodiversity Support**: Native plants and pollinator-friendly gardening practices
- **Waste Reduction**: Composting programs and circular resource use

### Climate Adaptation
- **Food Security**: Local production reducing vulnerability to supply disruptions
- **Heat Island Mitigation**: Green spaces cooling urban environments
- **Resilient Communities**: Local food systems supporting climate adaptation
- **Educational Impact**: Climate awareness through hands-on environmental stewardship

## Contributing

We welcome contributions from:
- Urban agriculture practitioners and community organizers
- Blockchain developers interested in social impact applications
- City planners and policy advocates
- Environmental and food justice organizations
- Residents interested in community garden development

### Development Guidelines
1. Follow community-centered design principles
2. Maintain comprehensive testing and documentation
3. Respect local governance and cultural practices
4. Include diverse community voices in decision-making

## Roadmap

### Phase 1: Foundation (Current)
- ✅ Core smart contract development
- ✅ Basic plot registry and allocation functionality
- ✅ Community governance framework

### Phase 2: Community Integration
- [ ] Mobile application for garden management
- [ ] GIS integration for mapping and planning
- [ ] Community notification and coordination systems

### Phase 3: Ecosystem Expansion
- [ ] Integration with local food distribution networks
- [ ] Partnership with agricultural education organizations
- [ ] Policy advocacy tools and resources

### Phase 4: Regional Networks
- [ ] Inter-community resource sharing
- [ ] Regional food system coordination
- [ ] Urban agriculture policy development

## Partnerships

We actively collaborate with:
- Urban agriculture organizations and community gardens
- Food justice and environmental equity groups
- City planning departments and municipal governments
- Agricultural extension services and educational institutions
- Local businesses supporting community food systems

## Support

- **Documentation**: [docs.urban-garden-collective.org](https://docs.urban-garden-collective.org)
- **Community**: [community.urban-garden-collective.org](https://community.urban-garden-collective.org)
- **Support**: support@urban-garden-collective.org
- **Discord**: [Urban Garden Collective](https://discord.gg/urban-garden-collective)

## License

This project is licensed under the GNU General Public License v3.0 - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- Urban gardeners and community organizers building food sovereignty
- Environmental justice advocates fighting for equitable green spaces
- City planners supporting urban agriculture integration
- Technology developers committed to community-centered solutions
- Academic researchers studying urban food systems and community resilience

---

**Built with 🌱 for urban communities and sustainable food systems**

*Empowering food sovereignty through blockchain technology and community organizing*