#!/usr/bin/env ruby

require "bundler/setup"
require "aws-sdk-s3"

class CurrentCluster
  attr_reader :region

  def initialize(params)
    @region = params.fetch(:region)
  end

  def list
    kops_clusters + eks_clusters
  end

  private

  def kops_clusters
    json = `kops get clusters --output json`
    JSON.parse(json)
      .map {|h| h.dig("metadata", "name")}
      .map {|str| str.split(".").first}
  end

  def eks_clusters
    json = `aws eks list-clusters --region=#{region}`
    JSON.parse(json).fetch("clusters")
  end
end

class ClusterTerraformStateFiles
  attr_reader :s3client, :bucket, :cluster_region

  # These prefixes identify terraform statefiles which do not belong to a
  # specific cluster, and which should therefore not be reported as orphaned by
  # this code
  IGNORE_PREFIXES = [
    "cloud-platform-environments",
    "cloud-platform-concourse",
    "concourse-pipelines",
    "global-resources",
    "terraform.tfstate", # AWS account baseline?
  ]

  def initialize(params)
    @s3client = params.fetch(:s3)
    @bucket = params.fetch(:bucket)
    @cluster_region = params.fetch(:cluster_region)
  end

  def list
    exclude_current_clusters(
      exclude_non_cluster_files(
        all_statefiles_in_bucket
      )
    )
  end

  private

  def exclude_current_clusters(list)
    list.reject do |file|
      cluster = file.split("/")[1]
      current_clusters.include?(cluster)
    end
  end

  def current_clusters
    @current_clusters ||= CurrentCluster.new(region: cluster_region).list
  end

  def exclude_non_cluster_files(list)
    list.reject do |file|
      prefix = file.split("/").first
      IGNORE_PREFIXES.include?(prefix)
    end
  end

  def all_statefiles_in_bucket
    s3client.bucket(bucket)
      .objects
      .collect(&:key)
      .find_all { |key| key =~ /terraform.tfstate$/ }
  end
end


ctsf = ClusterTerraformStateFiles.new(
  s3: Aws::S3::Resource.new(region: "eu-west-1"),
  bucket: "cloud-platform-terraform-state",
  cluster_region: "eu-west-2",
)

pp ctsf.list
