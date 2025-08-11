import os
import sys
import yaml
import argparse
import re
import textwrap
import unicodedata
from datetime import datetime

from BacklogPy import Backlog

def main():
    parser = argparse.ArgumentParser(description='Export Backlog project data')
    parser.add_argument('project_key', help='Backlog project key (e.g., ABC)')
    args = parser.parse_args()

    SPACE = os.getenv("BACKLOG_SPACE")
    API_KEY = os.getenv("BACKLOG_API_KEY")
    PROJECT_KEY = args.project_key
    SUFFIX = os.getenv("BACKLOG_SUFFIX", "jp")  # jp または com

    # 環境変数のチェック
    if not SPACE:
        print("Error: BACKLOG_SPACE environment variable is required", file=sys.stderr)
        sys.exit(1)
    if not API_KEY:
        print("Error: BACKLOG_API_KEY environment variable is required", file=sys.stderr)
        sys.exit(1)

    bl = Backlog(SPACE, API_KEY, suffix=SUFFIX)

    project_info = fetch_project(bl, PROJECT_KEY)
    export_project(project_info)
    project_id = project_info['id']

    issues = fetch_issues(bl, project_id)
    export_issues(issues)
    export_issues_table(issues)

    create_readme(project_info, len(issues))


def fetch_project(bl, project_key):
    print("Fetching project information...")

    project_response = bl.get_project(project_key)
    if project_response.status_code != 200:
        print(f"Project API error: {project_response.text}")
        sys.exit(1)

    project_info = project_response.json()

    project_info_export = {
        "id": project_info['id'],
        "projectKey": project_info['projectKey'],
        "name": project_info['name'],
    }

    return project_info_export


def export_project(project_info):
    # Write project info to file
    filename = f"project_{project_info['projectKey']}.yml"

    with open(filename, 'w', encoding='utf-8') as f:
        yaml.dump(project_info, f, allow_unicode=True, sort_keys=False)

    print(f"  Wrote {filename}")


def fetch_issues(bl, project_id):
    print("Fetching issues...")

    issues = []
    offset = 0
    count = 100  # 1回のリクエストで取得する件数
    #count = 10

    while True:
        issues_response = bl.get_issue_list(project_id=project_id, offset=offset, count=count)
        if issues_response.status_code != 200:
            print(f"Issues API error: {issues_response.text}")
            sys.exit(1)

        page_issues = issues_response.json()
        if not page_issues:  # 空のページが返された場合は終了
            break

        issues.extend(page_issues)
        print(f"Retrieved {len(page_issues)} issues (total: {len(issues)})")

        if len(page_issues) < count:  # 取得件数が要求件数より少ない場合は最後のページ
            break

        offset += count
        #break  # # For testing, we break after the first page

    issues_export = []
    for issue in issues:
        issue_export = {
            "id": issue['id'],
            "issueKey": issue['issueKey'],
            "keyId": issue['keyId'],
        }
        issue_export["issueType"] = issue['issueType']['name']
        issue_export["summary"] = issue['summary']
        issue_export["description"] = issue.get('description', '')
        issue_export["priority"] = issue['priority']['name']
        if issue.get('resolution', None):
            issue_export["resolution"] = issue.get('resolution').get('name', 'Unresolved')
        issue_export["status"] = issue['status']['name']
        if issue.get('assignee', None):
            issue_export["assignee"] = issue.get('assignee').get('name', 'Unassigned')
        if issue.get("categories", None):
            issue_export["categories"] = [cat['name'] for cat in issue.get('categories', [])]
        if issue.get("versions", None):
            issue_export["versions"] = [ver['name'] for ver in issue.get('versions', [])]
        if issue.get("startDate", None):
            issue_export["startDate"] = issue.get("startDate")
        if issue.get("dueDate", None):
            issue_export["dueDate"] = issue.get("dueDate")
        issue_export["createdUser"] = issue['createdUser']['name']
        issue_export["created"] = issue['created']
        issue_export["updatedUser"] = issue.get('updatedUser', {}).get('name', 'Unknown')
        issue_export["updated"] = issue['updated']

        issue_export["comments"] = fetch_issue_comments(bl, issue['id'])

        issues_export.append(issue_export)

    return issues_export


def fetch_issue_comments(bl, issue_id):
    print(f"Fetching comments for issue {issue_id}...")

    issue_comments = []
    count = 100
    min_id = None

    while True:
        comments_response = bl.get_comment_list(issue_id, min_id=min_id, count=count, order="asc")
        if comments_response.status_code == 200:
            page_comments = comments_response.json()
            if not page_comments:
                break
            issue_comments.extend(page_comments)
            if len(page_comments) < count:
                break
            # 次のページのmin_idを設定（最後のコメントのIDの次）
            min_id = page_comments[-1]['id'] + 1
        else:
            print(f"Failed to get comments for issue {issue_id}: {comments_response.status_code}")
            break

    # コメントのエクスポート形式を整形
    issue_comments_export = []
    for comment in issue_comments:
        comment_export = {
            "id": comment['id'],
            "content": comment['content'],
            "createdUser": comment['createdUser']['name'],
            "created": comment['created'],
            "updated": comment['updated']
        }
        issue_comments_export.append(comment_export)

    return issue_comments_export


def export_issues(issues):
    # Create issues directory
    issues_dir = "issues"
    if not os.path.exists(issues_dir):
        os.makedirs(issues_dir)
    
    print(f"Writing {len(issues)} issues to individual files...")
    
    for issue in issues:
        # Create filename using issue key and summary
        # Remove/replace invalid filename characters
        safe_summary = sanitize_filename(issue['summary'])
        filename = f"{issue['issueKey']}_{safe_summary}.yml"
        filepath = os.path.join(issues_dir, filename)
        
        with open(filepath, 'w', encoding='utf-8') as f:
            yaml.dump(issue, f, allow_unicode=True, sort_keys=False)
        
        print(f"  Wrote {filename}")
    
    print(f"All {len(issues)} issues exported to {issues_dir}/ directory")


def get_display_width(text):
    """Calculate display width considering East Asian characters"""
    width = 0
    for char in text:
        if unicodedata.east_asian_width(char) in ('F', 'W'):
            width += 2  # Full-width characters take 2 columns
        else:
            width += 1  # Half-width characters take 1 column
    return width


def pad_text_to_width(text, target_width):
    """Pad text to target display width considering East Asian characters"""
    current_width = get_display_width(text)
    padding = target_width - current_width
    return text + ' ' * max(0, padding)


def export_issues_table(issues):
    """Export issues as a Markdown table"""
    filename = "issue_list.md"
    
    # Calculate max display widths for each column
    max_issue_key_width = max(get_display_width(issue['issueKey']) for issue in issues) if issues else 0
    max_status_width = max(get_display_width(issue['status']) for issue in issues) if issues else 0
    max_created_width = 10  # YYYY-MM-DD format is always 10 characters
    max_updated_width = 10  # YYYY-MM-DD format is always 10 characters
    
    # Ensure minimum width based on header
    max_issue_key_width = max(max_issue_key_width, get_display_width('Issue Key'))
    max_status_width = max(max_status_width, get_display_width('Status'))
    max_created_width = max(max_created_width, get_display_width('Created'))
    max_updated_width = max(max_updated_width, get_display_width('Updated'))
    
    with open(filename, 'w', encoding='utf-8') as f:
        # Write table header
        f.write("# Issues List\n\n")
        issue_key_header = pad_text_to_width('Issue Key', max_issue_key_width)
        status_header = pad_text_to_width('Status', max_status_width)
        created_header = pad_text_to_width('Created', max_created_width)
        updated_header = pad_text_to_width('Updated', max_updated_width)
        f.write(f"| {issue_key_header} | {status_header} | {created_header} | {updated_header} | Summary |\n")
        f.write(f"|{'-' * (max_issue_key_width + 2)}|{'-' * (max_status_width + 2)}|{'-' * (max_created_width + 2)}|{'-' * (max_updated_width + 2)}|----------|\n")
        
        # Write table rows
        for issue in issues:
            issue_key = pad_text_to_width(issue['issueKey'], max_issue_key_width)
            status = pad_text_to_width(issue['status'], max_status_width)
            created = pad_text_to_width(issue['created'][:10] if issue['created'] else '', max_created_width)
            updated = pad_text_to_width(issue['updated'][:10] if issue['updated'] else '', max_updated_width)
            summary = issue['summary'].replace('|', '\\|').replace('\n', ' ')  # Escape pipes and newlines
            
            f.write(f"| {issue_key} | {status} | {created} | {updated} | {summary} |\n")
    
    print(f"Issues table exported to {filename}")


def sanitize_filename(filename):
    # Replace invalid filename characters with underscores
    # Invalid characters: / \ : * ? " < > |
    sanitized = re.sub(r'[\s/\\:*?"<>|]', '_', filename)
    # Remove leading/trailing whitespace and dots
    sanitized = sanitized.strip(' .')
    # Limit length to 100 characters to avoid filesystem limits
    if len(sanitized) > 100:
        sanitized = sanitized[:100].rstrip(' .')
    return sanitized


def create_readme(project_info, issues_count):
    now = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
    
    readme_content = textwrap.dedent(f"""
        # Backlog Project Export
        
        This directory contains exported data from Backlog project **{project_info['name']}** (`{project_info['projectKey']}`).
        
        ## Export Information
        
        - **Project Key**: {project_info['projectKey']}
        - **Project Name**: {project_info['name']}
        - **Project ID**: {project_info['id']}
        - **Export Date**: {now}
        - **Total Issues Exported**: {issues_count}
        
        ## Directory Structure
        
        ```
        .
        ├── README.md                    # This file
        ├── project_{project_info['projectKey']}.yml    # Project information
        └── issues/                      # Individual issue files
            ├── {project_info['projectKey']}-1_Issue_Title.yml
            ├── {project_info['projectKey']}-2_Another_Issue.yml
            └── ...
        ```
        
        ## File Formats
        
        - **Project File**: Contains basic project metadata (ID, key, name)
        - **Issue Files**: Each issue is exported as a separate YAML file containing:
          - Issue metadata (ID, key, summary, description)
          - Status, priority, assignee information
          - Categories and versions
          - Dates (created, updated, start, due)
          - All comments with timestamps and authors
        
        ## File Naming Convention
        
        Issue files are named using the pattern: `{{issueKey}}_{{summary}}.yml`
        
        Where:
        - `issueKey`: The Backlog issue key (e.g., {project_info['projectKey']}-123)
        - `summary`: Issue summary with invalid filename characters replaced by underscores
        
        ## Usage Notes
        
        - All files are in YAML format for easy reading and processing
        - Comments are included within each issue file
    """).strip()
    
    with open('README.md', 'w', encoding='utf-8') as f:
        f.write(readme_content)
    
    print("README.md created with export information")


if __name__ == "__main__":
    main()