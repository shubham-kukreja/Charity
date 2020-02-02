pragma solidity ^0.4.17;

contract Charity {
    struct CampaignRequest {
        string purpose;
        uint256 value;
        address vendor;
        bool donationComplete;
        uint256 approvalCount;
        mapping(address => bool) approval;
    }
    address public campaignHead;
    mapping(address => bool) public donors;
    uint256 public minimumDonation;
    uint256 public donorsCount;
    CampaignRequest[] public requests;

    function Charity(uint256 minimum) public {
        campaignHead = msg.sender;
        minimumDonation = minimum;
        donorsCount = 0;
    }

    function donate() public payable {
        require(msg.value >= minimumDonation);
        donors[msg.sender] = true;
        donorsCount;
    }

    modifier restricted() {
        require(msg.sender == campaignHead);
        _;
    }

    function createRequest(string _purpose, uint256 _value, address _vendor)
        public
        restricted
    {
        CampaignRequest memory newRequest = CampaignRequest({
            purpose: _purpose,
            value: _value,
            vendor: _vendor,
            donationComplete: false,
            approvalCount: 0
        });
        requests.push(newRequest);
    }

    function approveRequest(uint256 index) public {
        CampaignRequest storage request = requests[index];
        require(donors[msg.sender]);
        require(!request.approval[msg.sender]);
        request.approval[msg.sender] = true;
        request.approvalCount++;
    }

    function finalizeCampaignRequest(uint256 index) public restricted {
        CampaignRequest storage request = requests[index];
        require(!request.donationComplete);
        require(request.approvalCount > (donorsCount / 2));
        request.donationComplete = true;
        request.vendor.transfer(request.value);
    }
}
