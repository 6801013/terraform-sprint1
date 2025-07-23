# スプリント1：AWS環境構築（Terraform）

このリポジトリは、スプリント1で作成したTerraformコードをまとめたものです。
AWS上にWebサーバおよびAPIサーバを構築するインフラ構成を定義しています。

## 構成概要

- Terraformを使用して以下を構築：
- Amazon LinuxベースのWebサーバ
- Amazon LinuxベースのAPIサーバ
- サーバの構築後、Tera Termを用いてそれぞれにSSHログインし、セットアップを実施

## 使用技術

- Terraform
- AWS（EC2, VPC など）
- Tera Term（サーバ設定用のSSHクライアント）

## Webサーバ／APIサーバの中身

各サーバ内のミドルウェアや設定は、Tera Term経由で個別に設定しています。
