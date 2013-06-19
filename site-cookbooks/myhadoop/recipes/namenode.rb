service "hadoop-hdfs-namenode" do
    action :nothing
end

package "hadoop-hdfs-namenode" do
    action :install
end

directory "/data/1/dfs/nn" do
    action :create
    group "hadoop"
    recursive true
end

namenodes = search(:node,"chef_environment:#{node.chef_environment} AND role:namenode")
if namenodes.length == 2
    datanodes = search(:node,"chef_environment:#{node.chef_environment} AND role:datanode")
    template "/etc/hadoop/conf/core-site.xml" do
        source "core-site.xml.erb"
        group "hadoop"
        variables (:namenode => namenodes,
                   :ha => true,
                   :journalnodes => datanodes)
        notifies :start, "service[hadoop-hdfs-datanode]", :immediately
    end
else
    # in case of 3 or more nns it will fallback to the 1
    template "/etc/hadoop/conf/core-site.xml" do
        source "core-site.xml.erb"
        group "hadoop"
        variables (:namenode => namenodes.first,
                   :ha => false)
    end
end

bash "format hdfs node" do
    user "hdfs"
    code "hdfs namenode -format"
    creates "/var/lib/hadoop-hdfs/cache/hdfs/dfs/name/current/VERSION"
    notifies :start, "service[hadoop-hdfs-namenode]", :immediately
end
