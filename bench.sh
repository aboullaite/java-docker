# Our containers
declare -a jcon=("aot" "cdc" "plain" "mod" "graal")

# Make sure that no container already exist & run the containers
for i in "${jcon[@]}"
do
    #Clean up old containers
    docker rm $i > /dev/null
    docker run --name $i dc/$i > /dev/null
done
# Get the startup time for each container
echo "Image| size| Startup"
for i in "${jcon[@]}"
do
    START=$(docker inspect --format='{{.State.StartedAt}}' $i | xargs gdate +%s%3N -d)
    STOP=$(docker inspect --format='{{.State.FinishedAt}}' $i | xargs gdate +%s%3N -d)
    SIZE=$(docker image inspect dc/$i --format='{{.Size}}' | awk '{ foo = $1 / 1024 / 1024 ; print foo "MB" }')
    echo "$i| $SIZE| $(($STOP-$START)) ms"
done