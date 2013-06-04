#
# Cookbook Name:: hadoop_sample
# Recipe:: default
#
# Copyright 2013, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

# The example is taken from http://www.analyticalway.com/?p=124

directory "/var/lib/hdfs/zipcode_sort" do
    owner "hdfs"
end

cookbook_file "/var/lib/hdfs/zipcode_sort/map.py" do
    source "zipcode/map.py"
end

cookbook_file "/var/lib/hdfs/zipcode_sort/reducer.py" do
    source "zipcode/reducer.py"
end

package "unzip"

remote_file "/var/lib/hdfs/zipcode_sort/zbp07detail.zip" do
    source "http://www2.census.gov/econ2007/CBP_CSV/zbp07detail.zip"
end

bash "extract zbp07detail.zip" do
    cwd "/var/lib/hdfs/zipcode_sort"
    user "hdfs"
    command <<-EOB
    unzip zbp07detail.zip
    hadoop fs -mkdir -r /user/mydir
    hadoop fs -put zbp07detail.txt /user/mydir/
    EOB
end


# you can launch all that stuff with
# hadoop jar /usr/lib/hadoop-0.20-mapreduce/contrib/streaming/hadoop-streaming-2.0.0-mr1-cdh4.2.1.jar -input /user/mydir/zbp07detail.txt -output /user/mydir/out -mapper ./map.py -reducer ./reducer.py -file ./map.py -file ./reducer.py
