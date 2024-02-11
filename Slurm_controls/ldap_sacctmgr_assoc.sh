# Group name to which users will be added
group_name="GROUP_NAME_HERE"


#show all users from a group in a line by line basis
getent group $group_name | cut -d: -f4 | tr ',' '\n' > a
#show all users on an account in a line by line basis
sacctmgr show associations where account=$group_name --parsable | awk -F'|' 'NR>2 {print $3}' > b
#compare two files and output who is in the UNIX group but not on sacctmgr
comm -23 <(sort a) <(sort b) > users_to_add
#now diff compare to see who is in sacctmgr but not in UNIX group i.e. who shouldn't use the cluster
comm -13 <(sort a) <(sort b) > users_to_remove

# Check if the file exists
if [ ! -f "users_to_add" ]; then
    echo "Usernames file not found."
    exit 1
fi

# Loop through each username in the file and add them to the group
while IFS= read -r username || [ -n "$username" ]; do
    sacctmgr -i add user "$username" account="$group_name"
done < "users_to_add"


# Check if the file exists
if [ ! -f "users_to_remove" ]; then
    echo "Usernames file not found."
    exit 1
fi

# Loop through each username in the file and remove them from the group
while IFS= read -r username || [ -n "$username" ]; do
    sacctmgr -i remove user "$username" account="$group_name"
done < "users_to_remove"
