import json
import os

def consolidate_reports(input_dir, output_file):
    """Merge all per-subscription reports into a single global report."""
    consolidated_data = {}

    # Iterate through all files in the directory
    for report_file in os.listdir(input_dir):
        if report_file.endswith(".json"):
            subscription_id = report_file.split("_")[-1].replace(".json", "")
            with open(os.path.join(input_dir, report_file), "r") as f:
                consolidated_data[subscription_id] = json.load(f)

    # Save consolidated report
    with open(output_file, "w") as f:
        json.dump(consolidated_data, f, indent=4)

    print(f"Global report saved to: {output_file}")

if __name__ == "__main__":
    input_directory = "vm_quota_usage_reports"
    output_file = "global_quota_usage_report.json"
    consolidate_reports(input_directory, output_file)


import json
import csv
import os

def generate_summary_csv(input_dir, output_csv):
    """Generate a CSV summary of VM quota usage across all subscriptions."""
    fieldnames = ["Subscription ID", "Region", "Resource Name", "Current Usage", "Limit", "Unit"]

    with open(output_csv, "w", newline="") as csvfile:
        writer = csv.DictWriter(csvfile, fieldnames=fieldnames)
        writer.writeheader()

        # Process each subscription report
        for report_file in os.listdir(input_dir):
            if report_file.endswith(".json"):
                subscription_id = report_file.split("_")[-1].replace(".json", "")
                with open(os.path.join(input_dir, report_file), "r") as f:
                    data = json.load(f)

                    for region, resources in data.items():
                        if isinstance(resources, list):  # Skip error entries
                            for resource in resources:
                                writer.writerow({
                                    "Subscription ID": subscription_id,
                                    "Region": region,
                                    "Resource Name": resource["resource_name"],
                                    "Current Usage": resource["current_usage"],
                                    "Limit": resource["limit"],
                                    "Unit": resource["unit"]
                                })

    print(f"Summary CSV generated: {output_csv}")

if __name__ == "__main__":
    input_directory = "vm_quota_usage_reports"
    output_file = "quota_usage_summary.csv"
    generate_summary_csv(input_directory, output_file)
