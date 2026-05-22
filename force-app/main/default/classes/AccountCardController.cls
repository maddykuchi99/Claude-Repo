/**
 * Controller for AccountCard Lightning Web Component
 * Retrieves account records with relevant fields for display
 * Deploying through MCP
 */
public with sharing class AccountCardController {

    /**
     * Retrieves all Account records with key fields
     * @return List of Account records with Name, Industry, Phone, AnnualRevenue, Rating
     */
    @AuraEnabled(cacheable=true)
    public static List<Account> getAccounts() {
        try {
            return [
                SELECT Id, Name, Industry, Phone, AnnualRevenue, Rating
                FROM Account
                WITH USER_MODE
                ORDER BY Name ASC
                LIMIT 1000
            ];
        } catch (Exception e) {
            throw new AuraHandledException('Error retrieving accounts: ' + e.getMessage());
        }
    }

    /**
     * Get account count for display
     * @return Total number of accounts
     */
    @AuraEnabled(cacheable=true)
    public static Integer getAccountCount() {
        try {
            return [SELECT COUNT() FROM Account WITH USER_MODE];
        } catch (Exception e) {
            throw new AuraHandledException('Error retrieving account count: ' + e.getMessage());
        }
    }
}
