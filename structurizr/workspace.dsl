workspace "Coroperate Lending Platform" "Coroperate Lending Platform Architecture" {
    !identifiers hierarchical

    model {
        ##################################################### CLP AKTORZY
        banker = person "Bankier" {
            description "Pracownik biznesowy - Główny Aktor"
            properties {
                "structurizr.url" "https://dodac/link/do/dokumentacji"
            }
        }

        dziuk = person "Dziuk" {
            description "Pracownik jednostki umów kredytowych"
            properties {
                "structurizr.url" "https://dodac/link/do/dokumentacji"
            }
        }

        creditPartner = person "Partner Kredytowy" {
            description "Pracownik jednostki Umów Kredytowych"
            properties {
                "structurizr.url" "https://dodac/link/do/dokumentacji"
            }
        }

        auditor = person "Audytor" {
            description "Prowadzi nadzór oraz weryfikuje historyczne dane"
            properties {
                "structurizr.url" "https://dodac/link/do/dokumentacji"
            }
        }

        ##################################################### CLP DEFINICJA TECHNICZNA
        clp = softwareSystem "Corporate Lending Platform" {
            tags "CLP-TAG"

            fe = container "CLP Frontend" {
                tags "Angular"
                feTtl = component "Limit process FE"
                feTty = component "Decision process FE"
                feTta = component "Agreement process FE"
            }

            ttl = container "Limit Process - TTL" {
                tags "Spring" "Process"

                properties {
                    "structurizr.url" "https://dodac/link/do/dokumentacji"
                }
            }
            tty = container "Decision Process - TTY" {
                tags "Spring" "Process"
                properties {
                    "structurizr.url" "https://dodac/link/do/dokumentacji"
                }
            }
            tta = container "Agreement Process - TTA" {
                description "(Pół)automatyczny proces generowania dokumetów do decyzji podjętych w CLP."
                tags "Spring" "Process"
                properties {
                    "structurizr.url" "https://dodac/link/do/dokumentacji"
                }
            }
            tasks = container "Task Manager" {
                tags "Spring"
            }
            checklist = container "Checklist" {
                description "Checklista kowanantów i warunków uruchomienia."
                tags "Spring"
            }
            backend = container "Backend" {
                description "Monolit modularny - w trakcie wydzielania kolejnych domen DDD"
                tags "Spring"

                pricingOrder = component "PricingOrder"
                pricingDecision = component "PricingDecision"
                products = component "Products"
                customer = component "Customer"
            }
            rm = container "Rest Mediator" {
                tags "Spring"
            }
            os = container "Organization Structure" {
                tags "Spring"
            }
            apiGw = container "Api Gateway" {
                tags "Spring"
            }
            backendDB = container "BE Schema" "Backend Schema" "Oracle" {
                tags "Database" "Oracle"
            }
            ttlDB = container "TTL Schema" "Limit process Schema" "Oracle" {
                tags "Database" "Oracle"
            }
            ttyDB = container "TTY Schema" "Decision process Schema" "Oracle" {
                tags "Database" "Oracle"
            }
            ttaDB = container "TTA Schema" "Agreement process Schema" "Oracle" {
                tags "Database" "Oracle"
            }
            checklistDBOracle = container "CHL Data Schema" "Checklist Schema" "Oracle" {
                tags "Database" "Oracle"
            }
            checklistDBMongo = container "CHL Conf Schema" "Checklist Schema" "Mongo" {
                tags "Database" "Mongo"
            }
        }

        ##################################################### CLP SYSTEMY ZEWNĘTRZNE
        salesforce = softwareSystem "SalesForce" {
            tags "EXTERNAL-SYSTEM-TAG"
            description "Platforma do zarządzania relacjami z klientami (CRM)"
        }
        de = softwareSystem "Decision Engine" {
            tags "EXTERNAL-SYSTEM-TAG"
        }
        ccm = softwareSystem "CCM" {
            tags "EXTERNAL-SYSTEM-TAG"
        }
        ecm = softwareSystem "ECM" {
            tags "EXTERNAL-SYSTEM-TAG"
        }
        docgen = softwareSystem "DOC_GEN" {
            tags "EXTERNAL-SYSTEM-TAG"
        }
        spectrum = softwareSystem "Spectrum" {
            tags "EXTERNAL-SYSTEM-TAG"
        }


        ##################################################### POWIĄZANIA TTL
        # Powiązania systemowe Limit procesu TTL
        clp.ttl -> clp.backend "Reads customer products, replicates after decision state"
        clp.ttl -> clp.tasks "Manage tasks for user"
        clp.ttl -> de "Liczy rating"
        clp.ttl -> clp.ttlDB "Reads from and writes to"

        # Aktorzy Limit procesu TTL
        banker -> clp.ttl "Uses"
        auditor -> clp.ttl "Monitors"

        ##################################################### POWIĄZANIA TTY
        # Powiązania Decision procesu TTY
        clp.tty -> clp.ttyDB "Reads from and writes to"
        clp.tty -> clp.backend "Uses"
        clp.tty -> clp.tasks "Manage tasks for user"
        clp.tty -> de "Liczy profitability"
        clp.backend -> clp.backendDB "Reads from and writes to"
        clp.checklist -> clp.checklistDBOracle "Reads from and writes to"
        clp.checklist -> clp.checklistDBMongo "Reads from and writes to"

        # Użytkownicy Limit procesu TTL
        banker -> clp.tty "Uses"
        auditor -> clp.tty "Monitors"

        ##################################################### POWIĄZANIA TTA
        # Powiązania Agreement procesu TTA
        clp.tta -> clp.backend "Reads decision data"
        clp.tta -> clp.checklist "Reads decision data"
        clp.tta -> clp.ttaDB "Reads from and writes to" "JPA/SSL"
        clp.tta -> clp.tasks "Manage TTA tasks for user"
        clp.tta -> salesforce "Synchronizes prcess"
        clp.tta -> ccm "Reads documents"
        clp.tta -> ecm "Stores documents"
        clp.tta -> docgen "Genertes documents"
        clp.tta -> spectrum "Generuje ofertę"

        # Użytkownicy Agreement procesu TTA
        banker -> clp.tta "Provides documents agreement data"
        dziuk -> clp.tta "Approves, modifies documents data"
        auditor -> clp.tta "Verifies historical agreements documets correctness"

        ##################################################### POZOSTAŁE POWIĄZANIA CLP
        # TODO
    }

    views {
        systemContext clp "Context_Diagram" {
            include *
        }

        container clp "Container_Diagram" {
            include *
        }

        container clp "Container_Internal_Diagram" {
            include "element.parent==clp"
        }

        container clp "Limit_Process_Diagram" "Limit Process Diagram" {
            include "->clp.ttl->"
            include "clp.fe"
        }

        container clp "Decision_Process_Diagram" "Decision Process Diagram" {
            include "->clp.tty->"
            include "clp.fe"
        }

        container clp "Agreement_Process_Diagram" "Agreement Process Diagram" {
            include "->clp.tta->"
            include "clp.fe"
        }

        component clp.backend "Backend_Diagram" "Bakckend Domains Diagram" {
            include *
        }

        component clp.fe "Frontend_Diagram" {
            include *
        }

        styles {
            element "CLP-TAG" {
                background #F7C6C5
                icon "./icons/clp.png"
            }
            element "EXTERNAL-SYSTEM-TAG" {
                height 225
                background #CCCCCC
            }
            element "Spring" {
                stroke #99ed61
                strokeWidth 3
                color "#467328
                background #ffffff
                icon "./icons/springboot.png"
            }
            element "Process" {
                stroke #99ed61
                strokeWidth 3
                color "#467328
                background #e3fad4
                icon "./icons/springboot.png"
            }
            element "Angular" {
                background #418ED6
                icon "./icons/angular.svg"
            }
            element "Oracle" {
                stroke #DC2023
                strokeWidth 3
                color #DC2023
//                background #ffe0e1
                background #ffffff
                icon "./icons/oracle3.png"
            }
            element "Mongo" {
                stroke #138D4D
                strokeWidth 3
                color #138D4D
//                background #dbffec
                background #ffffff
                icon "./icons/mongo.png"
            }
            element "Database" {
                shape cylinder
            }
            element "Element" {
                color #ffffff
            }
            element "Person" {
                stroke #d7fced
                strokeWidth 3
                color #199b65
                width 300
                height 150
                background #d7fced
                shape person
            }
            element "Software System" {
                background #1eba79
                shape RoundedBox
            }
            element "Container" {
                background #418ED6
            }
        }
    }

    configuration {
        scope softwaresystem
    }


    //    !docs documentation
}
