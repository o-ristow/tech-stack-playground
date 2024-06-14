#!/bin/bash

# Base directory
BASE_DIR="kvm_setup"

# Function to create role directories and files
create_role() {
  role_path="$1"
  role_content="$2"
  
  dir_path="$BASE_DIR/roles/$(dirname "$role_path")"
  file_path="$BASE_DIR/roles/$role_path"

  mkdir -p "$dir_path"
  echo "$role_content" > "$file_path"
}

# Main playbook content
MAIN_PLAYBOOK_CONTENT="---
- name: Setup roles for KVM environment
  hosts: all
  become: true
  vars:
    users:
      sys_admin:
        name: sys_admin
        password: \"{{ 'password123' | password_hash('sha512') }}\"
        shell: /bin/bash
      vm_manager:
        name: vm_manager
        password: \"{{ 'password123' | password_hash('sha512') }}\"
        shell: /bin/bash
      kube_operator:
        name: kube_operator
        password: \"{{ 'password123' | password_hash('sha512') }}\"
        shell: /bin/bash
      docker_service:
        name: docker_service
        password: \"{{ 'password123' | password_hash('sha512') }}\"
        shell: /bin/bash

  tasks:
    - name: Include sys_admin role
      ansible.builtin.include_role:
        name: create_sys_admin
    - name: Include vm_manager role
      ansible.builtin.include_role:
        name: create_vm_manager
    - name: Include kube_operator role
      ansible.builtin.include_role:
        name: create_kube_operator
    - name: Include docker_service role
      ansible.builtin.include_role:
        name: create_docker_service
"

# Role content
SYS_ADMIN_CONTENT="---
- name: Create sys_admin user
  ansible.builtin.user:
    name: \"{{ users.sys_admin.name }}\"
    password: \"{{ users.sys_admin.password }}\"
    shell: \"{{ users.sys_admin.shell }}\"
    state: present
- name: Add sys_admin to sudoers
  ansible.builtin.copy:
    dest: /etc/sudoers.d/sys_admin
    content: \"{{ users.sys_admin.name }} ALL=(ALL) NOPASSWD:ALL\"
    mode: '0440'
"

VM_MANAGER_CONTENT="---
- name: Create vm_manager user
  ansible.builtin.user:
    name: \"{{ users.vm_manager.name }}\"
    password: \"{{ users.vm_manager.password }}\"
    shell: \"{{ users.vm_manager.shell }}\"
    state: present
- name: Add vm_manager to libvirt group
  ansible.builtin.user:
    name: \"{{ users.vm_manager.name }}\"
    groups: libvirt
    append: true
"

KUBE_OPERATOR_CONTENT="---
- name: Create kube_operator user
  ansible.builtin.user:
    name: \"{{ users.kube_operator.name }}\"
    password: \"{{ users.kube_operator.password }}\"
    shell: \"{{ users.kube_operator.shell }}\"
    state: present
- name: Add kube_operator to docker group
  ansible.builtin.user:
    name: \"{{ users.kube_operator.name }}\"
    groups: docker
    append: true
"

DOCKER_SERVICE_CONTENT="---
- name: Create docker_service user
  ansible.builtin.user:
    name: \"{{ users.docker_service.name }}\"
    password: \"{{ users.docker_service.password }}\"
    shell: \"{{ users.docker_service.shell }}\"
    state: present
- name: Add docker_service to docker group
  ansible.builtin.user:
    name: \"{{ users.docker_service.name }}\"
    groups: docker
    append: true
"

# Create the base directory
mkdir -p "$BASE_DIR"

# Create the roles directories and files
create_role "create_sys_admin/tasks/main.yml" "$SYS_ADMIN_CONTENT"
create_role "create_vm_manager/tasks/main.yml" "$VM_MANAGER_CONTENT"
create_role "create_kube_operator/tasks/main.yml" "$KUBE_OPERATOR_CONTENT"
create_role "create_docker_service/tasks/main.yml" "$DOCKER_SERVICE_CONTENT"

# Create the main playbook file
echo "$MAIN_PLAYBOOK_CONTENT" > "$BASE_DIR/main_playbook.yml"

echo "Directory structure and files have been created successfully."
