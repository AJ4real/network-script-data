RestoreInventory_Command:
    type: command
    name: restoreinventory
    debug: false
    description: Restores a previous inventory for a player after death.
    aliases:
        - rinv
        - restoreinv
        - invr
        - invrestore
        - inventoryrestore
    usage: /restoreinv <&lt>PlayerName<&gt> (1-10/Backup)
    permission: behrry.essentials.restoreinventory
    tab complete:
        - inject Online_Player_Tabcomplete Instantly
    script:
    # @ ██ [  Check Args ] ██
        - if <context.args.get[1]||null> == null || <context.args.get[3]||null> != null:
            - inject Command_Syntax Instantly
        
    # @ ██ [  Check Player ] ██
        - define User <context.args.get[1]>
        - inject Player_Verification Instantly

    # @ ██ [  Define Yaml ] ██
        - define key Behrry.Essentials.Cached_Inventories
        - define YamlSize <yaml[<[User].uuid>].read[<[Key]>].size||0>
        - define UID <yaml[<[User].uuid>].read[<[Key]>].get[<[YamlSize]>].before[Lasagna]||0>
        
    # @ ██ [  Check if inventory is empty // if using Backup ] ██
        - if <[YamlSize]> == 0 && <context.args.get[2]||null> != backup:
                - narrate "<[User].display_name><&r> <proc[Colorize].context[does not have a cached death inventory.|red]>"
        - else:
        # @ ██ [  Check Inventory # or if using Backup ] ██
            - define Arg2 <context.args.get[2]||1>
            - if <[Arg2]> == Backup:
                - if <[User].has_flag[Behrry.Essentials.inventory.backup]>:
                    - inventory set d:<[User].inventory> o:<[User].flag[Behrry.Essentials.inventory.backup]>
                    - narrate targets:<[User]> "<proc[Colorize].context[Your inventory was restored to a backup.|green]>"
                - else:
                    - narrate "<proc[Colorize].context[Player does not have a backup inventory.|red]>"
            
        # @ ██ [  Check Integer Arg ] ██
            - else if <[Arg2].is_integer>:
                - if <[Arg2]> > <[YamlSize]>:
                    - narrate "<&4>I<&2>nventory<&4>: <&6>[<&e><proc[Colorize].context[does not exist.|red]>"
                - else:
                    - define Cache <yaml[<[User].uuid>].read[<[Key]>].last>
                    - flag <[User]> Behrry.Essentials.inventory.backup:<[User].inventory.list_contents>
                    - inventory clear d:<[User].inventory>
                    - inventory set d:<[User].inventory> o:<[Cache].after[Lasagna]>
                # - ██ [ yaml id:<[User]> set <[Key]>:<-:<[Cache]> ] ██
                    - yaml id:<[User].uuid> savefile:data/pData/<[User].uuid>.yml
                    - if <[User]> != <player>:
                        - narrate targets:<player> "<&e>Player<&6><&co> <&f><[User].display_name><&r> <&e>Inventory<&6><&co><&f>[<context.args.get[2]||1>]<&f> Restored."
                    - narrate targets:<[User]> "<proc[Colorize].context[Your inventory before death was restored.|green]>"
            - else:
                - narrate "<proc[Colorize].context[Inventory cache must be an index number.|red]>"